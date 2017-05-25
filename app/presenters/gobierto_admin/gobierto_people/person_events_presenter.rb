# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventsPresenter
      def initialize(person)
        @person = person
      end

      def events_count
        @events_count ||= @person.events.count
      end

      def pending_events_count
        @pending_events_count ||= @person.events.pending.count
      end

      def published_events_count
        @published_events_count ||= @person.events.published.count
      end

      def past_events_count
        @past_events_count ||= @person.events.past.count
      end
    end
  end
end
