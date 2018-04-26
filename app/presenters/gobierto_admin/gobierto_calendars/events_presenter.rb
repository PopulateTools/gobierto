module GobiertoAdmin
  module GobiertoCalendars
    class EventsPresenter
      def initialize(collection)
        @collection = collection
      end

      def events
        @events ||= ::GobiertoCalendars::Event.by_collection(@collection)
      end

      def events_count
        @events_count ||= events.count
      end

      def upcoming_events_count
        @upcoming_events_count ||= events.upcoming.count
      end

      def pending_events_count
        @pending_events_count ||= events.pending.count
      end

      def published_events_count
        @published_events_count ||= events.published.count
      end

      def past_events_count
        @past_events_count ||= events.past.count
      end
    end
  end
end
