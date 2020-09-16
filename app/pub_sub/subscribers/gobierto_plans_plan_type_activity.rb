# frozen_string_literal: true

module Subscribers
  class GobiertoPlansPlanTypeActivity < ::Subscribers::Base
    def plan_type_created(event)
      create_activity_from_event(event, "gobierto_plans.plan_type_created")
    end

    def plan_type_updated(event)
      create_activity_from_event(event, "gobierto_plans.plan_type_updated")
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
