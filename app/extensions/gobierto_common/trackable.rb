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
        Rails.logger.debug("Skipping notifications for #{trackable.class.name} #{trackable.id}")
        return true
      end

      (self.class.send(:changed_attributes_to_notify) & Array(@changed)).each do |attribute_name|
        publish_changed(attribute_name)
        return true
      end

      if updated? && (Array(@changed) - self.class.send(:changed_attributes_to_notify)).any?
        publish_updated
      end

      true
    end

    protected

    def publish_updated
      broadcast_event("updated")
    end

    def publish_changed(attribute_name)
      broadcast_event("#{attribute_name}_changed") if changed?(attribute_name)
    end

    def broadcast_event(event_name)
      Rails.logger.debug("Broadcasting event \"#{event_name}\" with payload: #{event_payload}")
      Publishers::Trackable.broadcast_event(event_name, event_payload)
    end

    def event_payload
      { gid: trackable.to_gid, site_id: trackable.site_id, admin_id: (trackable.admin_id if trackable.respond_to?(:admin_id)) }
    end

    def store_changes
      @changed   = trackable.changed.map(&:to_sym)
      @persisted = trackable.persisted?

      # Always return successfully to avoid halting execution.
      true
    end

    def changed?(attribute_name)
      Array(@changed).include?(attribute_name.to_sym)
    end

    def updated?
      @persisted
    end
  end
end
