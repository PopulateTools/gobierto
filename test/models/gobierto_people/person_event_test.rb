require "test_helper"
require "support/concerns/user/subscribable_test"

module GobiertoPeople
  class PersonEventTest < ActiveSupport::TestCase
    include User::SubscribableTest

    def person_event
      @person_event ||= gobierto_people_person_events(:richard_published)
    end
    alias subscribable person_event

    def past_person_event
      @past_person_event ||= gobierto_people_person_events(:richard_published_past)
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

    def test_by_site_scope
      person_site = person_event.person.site
      subject = PersonEvent.by_site(person_site)

      assert_includes subject, person_event

      assert person_site == past_person_event.person.site
      assert_includes subject, past_person_event
    end

    def test_by_person_category_scope
      person_category = Person.categories[person_event.person.category]
      subject = PersonEvent.by_person_category(person_category)

      assert_includes subject, person_event

      assert person_category == Person.categories[past_person_event.person.category]
      assert_includes subject, past_person_event
    end

    def test_by_person_party_scope
      person_party = Person.parties[person_event.person.party]
      subject = PersonEvent.by_person_party(person_party)

      assert_includes subject, person_event

      assert person_party == Person.parties[past_person_event.person.party]
      assert_includes subject, past_person_event
    end

    def test_by_date_scope
      subject = PersonEvent.by_date(person_event.starts_at.to_date)

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
