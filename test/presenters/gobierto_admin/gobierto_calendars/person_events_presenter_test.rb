require "test_helper"

module GobiertoAdmin
  module GobiertoCalendars
    class EventsPresenterTest < ActiveSupport::TestCase
      def setup
        super
        @subject = EventsPresenter.new(collection)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def collection
        @collection ||= gobierto_common_collections(:richard_calendar)
      end

      def test_events_count
        assert_equal person.events.count, @subject.events_count
      end

      def test_pending_events_count
        assert_equal person.events.pending.count, @subject.pending_events_count
      end

      def test_published_events_count
        assert_equal person.events.published.count, @subject.published_events_count
      end

      def test_past_events_count
        assert_equal person.events.past.count, @subject.past_events_count
      end
    end
  end
end
