# frozen_string_literal: true

module Subscribers
  class GobiertoParticipationContributionContainerActivity < ::Subscribers::Base
    def contribution_container_created(event)
      create_activity_from_event(event, "gobierto_participation.contribution_container_created")
    end

    def contribution_container_updated(event)
      create_activity_from_event(event, "gobierto_participation.contribution_container_updated")
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
