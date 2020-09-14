# frozen_string_literal: true

module Subscribers
  class AdminGobiertoCalendarsActivity < ::Subscribers::Base
    def calendars_synchronized(event)
      create_activity_from_event(event, 'admin_gobierto_calendars.calendars_synchronized')
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       site_id: event.payload[:site_id],
                       admin_activity: true
    end
  end
end


