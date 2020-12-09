# frozen_string_literal: true

module Subscribers
  class GobiertoCmsSectionItemActivity < ::Subscribers::Base

    def section_item_created(event)
      create_activity_from_event(event, 'gobierto_cms.section_item_created')
    end

    def section_item_deleted(event)
      create_activity_from_event(event, 'gobierto_cms.section_item_deleted')
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
