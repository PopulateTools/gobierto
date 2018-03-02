# frozen_string_literal: true

module Subscribers
  class GobiertoPlansPlanActivity < ::Subscribers::Base
    def plan_created(event)
      create_activity_from_event(event, "gobierto_plans.plan_created")
    end

    def plan_updated(event)
      create_activity_from_event(event, "gobierto_plans.plan_updated")
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
