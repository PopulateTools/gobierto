# frozen_string_literal: true

module GobiertoParticipation
  class PastParticipationEventsController < GobiertoParticipation::EventsController
    def index
      @past_events = true
      super
    end
  end
end
