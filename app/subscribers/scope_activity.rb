# frozen_string_literal: true

module Subscribers
  class ScopeActivity < ::Subscribers::Base

    def scope_created(event)
      create_activity_from_event(event, 'scopes.scope_created')
    end

    def scope_updated(event)
      create_activity_from_event(event, 'scopes.scope_updated')
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
