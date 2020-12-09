# frozen_string_literal: true

module Subscribers
  class GobiertoCalendarsActivity < ::Subscribers::Base
    def updated(event)
      create_activity_from_event(event, 'updated')
    end

    def visibility_level_changed(event)
      create_activity_from_event(event, 'published')
    end

    def state_changed(event)
      create_activity_from_event(event, 'published')
    end

    private

    def create_activity_from_event(event, action)
      subject = GlobalID::Locator.locate event.payload[:gid]
      return unless subject.class.module_parent == GobiertoCalendars
      author = GobiertoAdmin::Admin.find_by id: event.payload[:admin_id]
      # When the author is nil, we can asume the action has been performed by an integration
      return if author.nil?
      action = subject.class.name.underscore.tr('/', '.') + '.' + action

      recipient = unless subject.collection.container.is_a?(Module)
                    subject.collection.container
                  else
                    nil
                  end

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
