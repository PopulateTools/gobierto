# frozen_string_literal: true

module Subscribers
  class UserActivity < ::Subscribers::Base
    def user_updated(event)
      create_activity_from_event(event, "users.user_updated")
    end

    private

    def create_activity_from_event(event, action)
      return if event.payload[:changes].empty?

      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       admin_activity: true
    end
  end
end
