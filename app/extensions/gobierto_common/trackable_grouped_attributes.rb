# frozen_string_literal: true

module GobiertoCommon
  module TrackableGroupedAttributes
    module ClassMethods
      attr_reader :trackable, :publisher, :subject, :event_prefix

      def notify_changed(*attribute_names, **opts)
        changed_attributes_to_notify.push(*attribute_names)
        if opts[:as].present?
          attributes_notification_alias[opts[:as]] = attribute_names
        end
      end

      def trackable_on(trackable)
        @trackable = trackable
      end

      def use_publisher(publisher)
        @publisher = publisher
      end

      def use_trackable_subject(subject)
        @subject = subject
      end

      def use_event_prefix(prefix)
        @event_prefix = "#{prefix}_"
      end

      private

      def changed_attributes_to_notify
        @changed_attributes_to_notify ||= []
      end

      def attributes_notification_alias
        @attributes_notification_alias ||= {}
      end
    end

    def self.prepended(base)
      base.extend(ClassMethods)

      base.class_eval do
        extend ActiveModel::Callbacks
        define_model_callbacks :save, only: [:before, :after]
        before_save :store_changes
        define_model_callbacks :destroy, only: [:after]
        after_destroy :store_changes
      end
    end

    def save
      run_callbacks(:save) do
        super
      end.tap { |result| perform_notifications if result }
    end

    def destroy
      run_callbacks(:destroy) do
        super
      end.tap { |result| perform_notifications if result }
    end

    def really_destroy!
      perform_notifications if super
    end

    def notify?
      return super if defined?(super)

      true
    end

    def trackable
      @trackable ||= send(self.class.trackable)
    end

    def publisher
      @publisher ||= self.class.publisher || Publishers::Trackable
    end

    def subject
      @subject ||= self.class.subject.present? ? send(self.class.subject) : trackable
    end

    private

    def perform_notifications
      unless notify?
        Rails.logger.debug("Skipping notifications for #{trackable.class.name} #{trackable.id}")
        return true
      end

      if new_record?
        publish_created
      elsif destroyed?
        publish_destroyed
      elsif archived?
        publish_archived
      else
        notifiable_list.each do |notifiable_name|
          publish_changed(notifiable_name)
        end
      end

      true
    end

    protected

    def notifiable_list
      ungrouped_notifiable_attributes = self.class.send(:changed_attributes_to_notify) & Array(@changed)
      notifiable_list = ungrouped_notifiable_attributes - attributes_notification_alias.values.flatten
      attributes_notification_alias.each do |alias_name, notifiable_attributes|
        notifiable_list << alias_name if (Array(@changed) & notifiable_attributes).any?
      end
      notifiable_list
    end

    def attributes_notification_alias
      @attributes_notification_alias ||= self.class.send(:attributes_notification_alias)
    end

    def publish_changed(attribute_name)
      broadcast_event("#{ event_prefix }#{ attribute_name }_changed") if changed?(attribute_name)
    end

    def publish_created
      broadcast_event("#{ event_prefix }created")
    end

    def publish_archived
      broadcast_event("#{ event_prefix }archived")
    end

    def publish_destroyed
      broadcast_event("#{ event_prefix }deleted")
    end

    def broadcast_event(event_name)
      Rails.logger.debug("Broadcasting event \"#{event_name}\" with payload: #{event_payload}")
      publisher.broadcast_event(event_name, event_payload)
    end

    def event_payload
      {
        gid: subject.to_gid,
        site_id: trackable.site_id,
        admin_id: (trackable.try(:admin_id) || try(:admin_id)),
        ip: try(:ip)
      }.merge(extra_event_payload)
    end

    def event_prefix
      self.class.event_prefix ||
        @event_prefix ||= if subject != trackable
                            trackable.class.name.demodulize.tableize + "_"
                          else
                            ""
                          end
    end

    def store_changes
      @changed = trackable.changed.map(&:to_sym)
      @persisted = trackable.persisted?
      @new_record = trackable.new_record?
      @archived = trackable.try(:archived?)

      true
    end

    def changed?(notifiable_name)
      Array(@changed).include?(notifiable_name.to_sym) ||
        attributes_notification_alias[notifiable_name].present? && (Array(@changed) & attributes_notification_alias[notifiable_name]).present?
    end

    def new_record?
      @new_record
    end

    def destroyed?
      !@persisted && !@new_record
    end

    def archived?
      @archived
    end

    def extra_event_payload
      return super if defined?(super)

      {}
    end
  end
end
