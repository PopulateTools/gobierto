# frozen_string_literal: true

module Subscribers
  class AdminGobiertoInvestmentsActivity < ::Subscribers::Base

    def project_attribute_changed(event)
      create_activity_from_event(event, "project_updated")
    end

    def project_created(event)
      create_activity_from_event(event, "project_created")
    end

    private

    def create_activity_from_event(event, action)
      subject = GlobalID::Locator.locate event.payload[:gid]

      return unless subject.class.module_parent == GobiertoInvestments

      author = GobiertoAdmin::Admin.find_by id: event.payload[:admin_id]

      # When the author is nil, we can asume the action has been performed by an integration
      return unless author.present?

      action = subject.class.name.underscore.tr("/", ".") + "." + action

      Activity.create! subject: subject,
                       author: author,
                       subject_ip: event.payload[:ip] || author.last_sign_in_ip,
                       action: action,
                       admin_activity: true,
                       site_id: event.payload[:site_id]
    end
  end
end
