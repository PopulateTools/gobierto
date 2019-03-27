# frozen_string_literal: true

module Subscribers
  class GobiertoParticipationPollActivity < ::Subscribers::Base

    def poll_created(event)
      create_activity_from_event(event, "gobierto_participation.poll_created")
    end

    def poll_updated(event)
      create_activity_from_event(event, "gobierto_participation.poll_updated")
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
