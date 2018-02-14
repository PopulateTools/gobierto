# frozen_string_literal: true

module Subscribers
  class GobiertoAttachmentsAttachmentActivity < ::Subscribers::Base
    def attachment_created(event)
      create_activity_from_event(event, "gobierto_attachments.attachment_created")
    end

    def attachment_updated(event)
      create_activity_from_event(event, "gobierto_attachments.attachment_updated")
    end

    private

    def create_activity_from_event(event, action)
      subject = event.payload[:subject]
      author = GobiertoAdmin::Admin.find_by id: event.payload[:author].id
      # When the author is nil, we can asume the action has been performed by an integration
      return if author.nil?

      recipient = unless subject.collection.container.is_a?(Module)
                    subject.collection
                  else
                    nil
                  end

      Activity.create! subject: subject,
                       author: author,
                       subject_ip: author.last_sign_in_ip,
                       action: action,
                       recipient: recipient,
                       admin_activity: true,
                       site_id: event.payload[:site_id]
    end
  end
end
