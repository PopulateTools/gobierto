# frozen_string_literal: true

module Subscribers
  class GobiertoParticipationContributionActivity < ::Subscribers::Base
    def contribution_created(event)
      create_activity_from_event(event, "gobierto_participation.contribution_created")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       subject_ip: event.payload[:ip],
                       action: action,
                       recipient: event.payload[:subject].contribution_container.process,
                       site_id: event.payload[:site_id],
                       admin_activity: false
    end
  end
end
