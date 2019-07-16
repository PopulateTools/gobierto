# frozen_string_literal: true

module Subscribers
  class AdminActivity < ::Subscribers::Base
    def invitation_created(event)
      create_activity_from_event(event, "admins.invitation_created")
    end

    def invitation_accepted(event)
      create_activity_from_event(event, "admins.invitation_accepted")
    end

    def admin_created(event)
      create_activity_from_event(event, "admins.admin_created")
    end

    def admin_updated(event)
      return if event.payload[:changes].empty?

      if event.payload[:changes].include?("authorization_level")
        create_activity_from_event(event, "admins.admin_authorization_level_updated")
        return if event.payload[:changes].keys.length == 1
      end

      create_activity_from_event(event, "admins.admin_updated")
    end

    def admin_group_member_created(event)
      create_activity_from_event(event, "admins.admin_group_member_created")
    end

    def admin_group_member_deleted(event)
      create_activity_from_event(event, "admins.admin_group_member_deleted")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       recipient: event.payload[:recipient],
                       action: action,
                       admin_activity: true
    end
  end
end
