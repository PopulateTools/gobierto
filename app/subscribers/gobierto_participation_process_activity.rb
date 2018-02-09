# frozen_string_literal: true

module Subscribers
  class GobiertoParticipationProcessActivity < ::Subscribers::Base
    def process_created(event)
      create_activity_from_event(event, "gobierto_participation.process_created")
    end

    def process_updated(event)
      create_activity_from_event(event, "gobierto_participation.process_updated")
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
