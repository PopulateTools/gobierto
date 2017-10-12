# frozen_string_literal: true

module Subscribers
  class GobiertoAttachmentsActivity < ::Subscribers::Base
    def updated(event)
      create_activity_from_event(event, 'updated')
    end

    def name_changed(event)
      create_activity_from_event(event, 'created')
    end

    private

    def create_activity_from_event(event, action)
      subject = GlobalID::Locator.locate event.payload[:gid]
      return unless subject.class.parent == GobiertoAttachments
      author = GobiertoAdmin::Admin.find_by id: event.payload[:admin_id]
      # When the author is nil, we can asume the action has been performed by an integration
      return if author.nil?
      action = subject.class.name.underscore.tr('/', '.') + '.' + action

      recipient = subject.collection.container

      Activity.create! subject: subject,
                       author: author,
                       subject_ip: author.last_sign_in_ip,
                       action: action,
                       recipient: recipient,
                       admin_activity: false,
                       site_id: event.payload[:site_id]
    end
  end
end
