# frozen_string_literal: true

module GobiertoAdmin
  module HasAdminNotificationSettings
    extend ActiveSupport::Concern

    # Stored settings are the base, so modules missing from the submission keep
    # their value. They are resolved on read instead of on assignment: forms may
    # receive notification_settings before the id that identifies the admin.
    def notification_settings
      (admin&.notification_settings || {}).merge(submitted_notification_settings)
    end

    def notification_settings=(value)
      submitted_notification_settings.merge!(parsed_notification_settings(value))
    end

    def send_notifications?(module_name)
      Admin.notifications_enabled?(notification_settings, module_name)
    end

    private

    def admin
      raise NotImplementedError, "#{self.class} must define #admin"
    end

    def submitted_notification_settings
      @submitted_notification_settings ||= {}
    end

    def parsed_notification_settings(value)
      submitted_settings = value.to_h.with_indifferent_access

      Admin::NOTIFICATION_MODULES.each_with_object({}) do |module_name, settings|
        next unless submitted_settings.key?(module_name)

        settings[module_name] = ActiveModel::Type::Boolean.new.cast(submitted_settings[module_name]).present?
      end
    end
  end
end
