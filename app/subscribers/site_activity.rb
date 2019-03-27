# frozen_string_literal: true

module Subscribers
  class SiteActivity < ::Subscribers::Base
    def site_created(event)
      create_activity_from_event(event, "sites.site_created")
    end

    def site_updated(event)
      return if event.payload[:changes].empty?

      if event.payload[:changes].include?("visibility_level")
        create_activity_from_event(event, "sites.site_visibility_updated")
        return if event.payload[:changes].keys.length == 1
      end

      if event.payload[:changes].include?("configuration_data")
        configuration_data = event.payload[:changes]["configuration_data"]
        if configuration_data.first["modules"] != configuration_data.last["modules"]
          create_activity_from_event(event, "sites.site_modules_updated")
          return if event.payload[:changes].keys.length == 1
        end
      end

      create_activity_from_event(event, "sites.site_updated")
    end

    def site_deleted(event)
      create_activity_from_event(event, "sites.site_destroyed")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       admin_activity: true
    end
  end
end
