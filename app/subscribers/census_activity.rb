# frozen_string_literal: true

module Subscribers
  class CensusActivity < ::Subscribers::Base
    def census_imported(event)
      create_activity_from_event(event, "census.census_imported")
    end

    private

    def create_activity_from_event(event, action)
      Activity.create! subject: event.payload[:subject],
                       author: event.payload[:author],
                       site_id: event.payload[:site_id],
                       subject_ip: event.payload[:ip],
                       action: action,
                       admin_activity: true
    end
  end
end
