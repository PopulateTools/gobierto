# frozen_string_literal: true

module GobiertoParticipation
  class ParticipationEventsController < GobiertoParticipation::ApplicationController
    def show
      @event = find_event
    end

    def index
      @issues = current_site.issues.alphabetically_sorted
      @participation_events = find_participation_events.page(params[:page])
    end

    private

    def find_participation_events
      ::GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted
    end

    def find_event
      find_participation_events.find_by_slug!(params[:id])
    end
  end
end
