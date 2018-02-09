# frozen_string_literal: true

module Subscribers
  class IssueActivity < ::Subscribers::Base
    def issue_created(event)
      create_activity_from_event(event, "issues.issue_created")
    end

    def issue_updated(event)
      create_activity_from_event(event, "issues.issue_updated")
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
