# frozen_string_literal: true

require "test_helper"
require "support/concerns/user/subscribable_test"
require "support/concerns/gobierto_common/sluggable_test"

module GobiertoCalendars
  class EventTest < ActiveSupport::TestCase
    include User::SubscribableTest
    include GobiertoCommon::SluggableTestModule

    def subject_class
      GobiertoCalendars::Event
    end

    def event
      @event ||= gobierto_calendars_events(:richard_published)
    end
    alias subscribable event

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def new_event
      subject_class.create!(
        title: "Person Event Title",
        starts_at: Time.zone.now,
        ends_at: Time.zone.now + 1.hour,
        site: sites(:madrid),
        collection: person.events_collection
      )
    end
    alias create_sluggable new_event

    def past_event
      @past_event ||= gobierto_calendars_events(:richard_published_past)
    end

    def test_valid
      assert event.valid?
    end

    def test_past_scope
      subject = subject_class.past

      assert_includes subject, past_event
      refute_includes subject, event
    end

    def test_upcoming_scope
      subject = subject_class.upcoming

      assert_includes subject, event
      refute_includes subject, past_event
    end

    def test_within_range_scope
      past_events = subject_class.within_range((1.year.ago)..(Time.zone.now))
      upcoming_events = subject_class.within_range((Time.zone.now)..(1.year.from_now))

      assert_includes past_events, past_event
      refute_includes past_events, event

      assert_includes upcoming_events, event
      refute_includes upcoming_events, past_event
    end

    def test_by_site_scope
      event_site = event.site
      subject = subject_class.by_site(event_site)

      assert_includes subject, event

      assert event_site == past_event.site
      assert_includes subject, past_event
    end

    # TODO
    def test_by_person_category_scope
      person_category = ::GobiertoPeople::Person.categories[person.category]
      subject = subject_class.by_person_category(person_category)

      assert_includes subject, event

      assert person_category == ::GobiertoPeople::Person.categories[person.category]
      assert_includes subject, past_event
    end

    # TODO
    def test_by_person_party_scope
      person_party = ::GobiertoPeople::Person.parties[person.party]
      subject = subject_class.by_person_party(person_party)

      assert_includes subject, event

      assert person_party == ::GobiertoPeople::Person.parties[person.party]
      assert_includes subject, past_event
    end

    def test_by_date_scope
      subject = subject_class.by_date(event.starts_at)

      assert_includes subject, event
      refute_includes subject, past_event
    end

    def test_past?
      assert past_event.past?
      refute event.past?
    end

    def test_upcoming?
      assert event.upcoming?
      refute past_event.upcoming?
    end

    def test_searchable_description
      assert event.searchable_description.include?("The President will analyze the progress of the measures adopted in the first days of the Government.")
      assert event.searchable_description.include?("El Presidente analizará la marcha de las medidas adoptadas en los primeros días de Gobierno.")
    end

    def test_searchable_description_when_empty
      new_event = ::GobiertoCalendars::Event.new
      assert_equal "", new_event.searchable_description
    end

    def test_destroy
      event.destroy

      assert event.slug.include?("archived-")
    end

    def test_public?
      assert event.public?

      person.draft!

      refute event.public?

      event.pending!

      refute event.public?

      person.active!

      refute event.public?
    end

    def test_slug_scope_check
      madrid_event = subject_class.create!(
        title: "Person Event Title",
        starts_at: Time.zone.now,
        ends_at: Time.zone.now + 1.hour,
        site: sites(:madrid),
        collection: person.events_collection
      )

      person = gobierto_people_people(:kali)
      site = sites(:santander)

      segovia_event = subject_class.create!(
        title: "Person Event Title",
        starts_at: Time.zone.now,
        ends_at: Time.zone.now + 1.hour,
        site: site,
        collection: person.events_collection
      )

      assert_equal madrid_event.slug, segovia_event.slug
    end
  end
end
