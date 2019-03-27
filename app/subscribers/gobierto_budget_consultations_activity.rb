# frozen_string_literal: true

module Subscribers
  class GobiertoBudgetConsultationsActivity < ::Subscribers::Base
    def updated(event)
      create_activity_from_event(event, "updated")
    end

    def visibility_level_changed(event)
      create_activity_from_event(event, "published")
    end

    private

    def create_activity_from_event(event, action)
      subject = GlobalID::Locator.locate event.payload[:gid]
      return unless subject.class.parent == GobiertoBudgetConsultations

      author = GobiertoAdmin::Admin.find event.payload[:admin_id]
      action = subject.class.name.underscore.tr("/", ".") + "." + action

      Activity.create! subject: subject,
                       author: author,
                       subject_ip: author.last_sign_in_ip,
                       action: action,
                       recipient: nil,
                       admin_activity: false,
                       site_id: event.payload[:site_id]
    end
  end
end
