# frozen_string_literal: true

module Subscribers
  class GobiertoAttachmentsAttachmentActivity < ::Subscribers::Base
    def attachment_created(event)
      create_activity_from_event(event, 'gobierto_attachments.attachment_created')
    end

    def attachment_updated(event)
      create_activity_from_event(event, 'gobierto_attachments.attachment_updated')
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
