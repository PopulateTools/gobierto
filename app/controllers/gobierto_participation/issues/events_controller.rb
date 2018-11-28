# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class EventsController < GobiertoParticipation::FilteredEventsController

      private

      def base_relation
        @issue = find_issue
        @base_relation ||= if valid_preview_token?
                             @issue.events
                           else
                             @issue.events.published
                           end
      end
    end
  end
end
