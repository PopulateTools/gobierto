# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class PastProcessEventsController < EventsController
      def index
        @past_events = true
        super
      end
    end
  end
end
