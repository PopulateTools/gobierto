# frozen_string_literal: true

module Subscribers
  class AdminGroupActivity < ::Subscribers::Base
    def admin_group_created(event)
      create_activity_from_event(event, "admin_groups.admin_group_created")
    end

    def admin_group_updated(event)
      return if event.payload[:changes].empty?

      create_activity_from_event(event, "admin_groups.admin_group_updated")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       admin_activity: true
    end
  end
end
