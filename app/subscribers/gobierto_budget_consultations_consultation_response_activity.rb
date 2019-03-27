# frozen_string_literal: true

module Subscribers
  class GobiertoBudgetConsultationsConsultationResponseActivity < ::Subscribers::Base
    def consultation_response_created(event)
      create_activity_from_event(event, "gobierto_budget_consultations.consultation_response_created")
    end

    def consultation_response_deleted(event)
      create_activity_from_event(event, "gobierto_budget_consultations.consultation_response_deleted")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       recipient: event.payload[:recipient],
                       site_id: event.payload[:site_id],
                       action: action,
                       admin_activity: true
    end
  end
end
