module GobiertoCommon
  module Trackable
    module ClassMethods
      attr_reader :trackable

      def notify_changed(*attribute_names)
        changed_attributes_to_notify.push(*attribute_names)
      end

      def trackable_on(trackable)
        @trackable = trackable
      end

      private

      def changed_attributes_to_notify
        @changed_attributes_to_notify ||= []
      end
    end

    def self.prepended(base)
      base.extend(ClassMethods)

      base.class_eval do
        extend ActiveModel::Callbacks
        define_model_callbacks :save, only: [:before, :after]
        before_save :store_changes
      end
    end

    def save
      perform_notifications if super
    end

    def notify?
      return super if defined?(super)

      true
    end

    def trackable
      @trackable ||= send(self.class.trackable)
    end

    private

    def perform_notifications
      unless notify?
        Rails.logger.debug("Skipping notifications for #{trackable.to_gid}")
        return true
      end

      if created?
        publish_created
        return true
      end

      self.class.send(:changed_attributes_to_notify).each do |attribute_name|
        publish_changed(attribute_name)
      end

      true
    end

    protected

    def publish_created
      broadcast_event("created")
    end

    def publish_changed(attribute_name)
      broadcast_event("#{attribute_name}_changed") if changed?(attribute_name)
    end

    def broadcast_event(event_name)
      Rails.logger.debug("Broadcasting event \"#{event_name}\" with payload: #{event_payload}")
      Publishers::Trackable.broadcast_event(event_name, event_payload)
    end

    def event_payload
      { gid: trackable.to_gid, site_id: trackable.site_id }
    end

    def store_changes
      @changed   = trackable.changed
      @persisted = trackable.persisted?

      # Always return successfully to avoid halting execution.
      true
    end

    def changed?(attribute_name)
      Array(@changed).include?(attribute_name.to_s)
    end

    def updated?
      @persisted
    end

    def created?
      !updated?
    end
  end
end
