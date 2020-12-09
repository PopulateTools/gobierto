# frozen_string_literal: true

module Subscribers
  class GobiertoPlansProjectActivity < ::Subscribers::Base
    def project_created(event)
      create_activity_from_event(event, "gobierto_plans.project_created")
    end

    def project_updated(event)
      create_activity_from_event(event, "gobierto_plans.project_updated")
    end

    def project_destroyed(event)
      create_activity_from_event(event, "gobierto_plans.project_destroyed")
    end

    def progresses_updated(event)
      create_activity_from_event(event, "gobierto_plans.progresses_updated")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       recipient: event.payload[:recipient],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       site_id: event.payload[:site_id],
                       admin_activity: true
    end
  end
end
