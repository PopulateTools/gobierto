require "test_helper"

module GobiertoPeople
  class PersonEventTest < ActiveSupport::TestCase
    def person_event
      @person_event ||= gobierto_people_person_events(:richard_approved)
    end

    def past_person_event
      @past_person_event ||= gobierto_people_person_events(:richard_approved_past)
    end

    def test_valid
      assert person_event.valid?
    end

    def test_past_scope
      subject = PersonEvent.past

      assert_includes subject, past_person_event
      refute_includes subject, person_event
    end

    def test_upcoming_scope
      subject = PersonEvent.upcoming

      assert_includes subject, person_event
      refute_includes subject, past_person_event
    end

    def test_past?
      assert past_person_event.past?
      refute person_event.past?
    end

    def test_upcoming?
      assert person_event.upcoming?
      refute past_person_event.upcoming?
    end
  end
end
