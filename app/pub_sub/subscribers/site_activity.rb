module Subscribers
  class SiteActivity < ::Subscribers::Base
    def site_created(event)
      create_activity_from_event(event)
    end

    def site_updated(event)
      create_activity_from_event(event)
    end

    def site_deleted(event)
      create_activity_from_event(event)
    end

    private

    def create_activity_from_event(event)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: event.name.split('/').last,
                       admin_activity: true

    end
  end
end

