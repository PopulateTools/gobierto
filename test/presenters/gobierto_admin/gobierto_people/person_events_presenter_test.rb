require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventsPresenterTest < ActiveSupport::TestCase
      def setup
        super
        @subject = PersonEventsPresenter.new(person)
      end

      def person
        @person ||= gobierto_people_people(:richard)
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
