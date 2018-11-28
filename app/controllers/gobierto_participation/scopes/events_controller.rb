# frozen_string_literal: true

module GobiertoParticipation
  module Scopes
    class EventsController < GobiertoParticipation::FilteredEventsController

      private

      def base_relation
        @scope = find_scope
        @base_relation ||= if valid_preview_token?
                             @scope.events
                           else
                             @scope.events.published
                           end
      end
    end
  end
end
