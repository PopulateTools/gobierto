# frozen_string_literal: true

module Subscribers
  class GobiertoCmsPageActivity < ::Subscribers::Base
    def page_created(event)
      create_activity_from_event(event, 'gobierto_cms.page_created')
    end

    def page_updated(event)
      create_activity_from_event(event, 'gobierto_cms.page_updated')
    end

    def page_deleted(event)
      create_activity_from_event(event, 'gobierto_cms.page_deleted')
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

