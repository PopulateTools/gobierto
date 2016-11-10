module Subscribers
  class SiteActivity < ::Subscribers::Base
    def site_created(event)
      return if event.payload[:subject].nil? || event.payload[:subject].new_record?

      create_activity_from_event(event)
    end

    def site_updated(event)
      return if event.payload[:changes].empty? || !event.payload[:subject].valid?

      create_activity_from_event(event)
    end

    def site_deleted(event)
      return if !event.payload[:subject].destroyed?

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

