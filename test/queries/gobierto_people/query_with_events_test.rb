# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"
require "factories/common_factory"
require "factories/gobierto_people/factory"

module GobiertoPeople
  class QueryWithEventsTest < ActiveSupport::TestCase

    include ::EventHelpers

    FAR_PAST = EventHelpers::TIME_ALIASES[:far_past]
    PAST = EventHelpers::TIME_ALIASES[:past]
    FUTURE = EventHelpers::TIME_ALIASES[:future]

    attr_accessor(
      :justice_department,
      :coca_cola_interest_group,
      :tamara,
      :site,
      :madrid,
      :badajoz,
      :ecology_department,
      :badajoz_department,
      :madrid_department,
      :industry_department
    )

    def setup
      super
      @justice_department = gobierto_people_departments(:justice_department)
      @madrid_department = @justice_department
      @coca_cola_interest_group = gobierto_people_interest_groups(:coca_cola)
      @tamara = gobierto_people_people(:tamara)
      @site = sites(:madrid)
      @madrid = sites(:madrid)

      # Custom Site
      @badajoz = CommonFactory.site
      @ecology_department = GobiertoPeople::Factory.department(name: "Ecology department", site: badajoz)
      @badajoz_department = @ecology_department
      @industry_department = GobiertoPeople::Factory.department(name: "Industry department", site: badajoz)
      # dos grupos de interes
      @bank_interest_group = GobiertoPeople::Factory.interest_group(name: "Bank interest group", site: badajoz)
      @oil_interest_group = GobiertoPeople::Factory.interest_group(name: "Oil interest group", site: badajoz)
    end

    def site_source
      site.events
    end

    def department_source
      justice_department.events
    end

    def interest_group_source
      coca_cola_interest_group.events
    end

    def person_source
      tamara.attending_events
    end

    def site_interest_groups_source
      site.interest_groups
    end

    def site_departments_source
      site.departments
    end

    def people_with_events_in_department_source
      justice_department.people.with_event_attendances(site)
    end

    def create_gift(person, department, params = {})
      GobiertoPeople::Factory.gift(params.merge(person: person, department: department))
    end

    def create_person(name, site)
      GobiertoPeople::Factory.person(name: name, site: site)
    end

    def create_invitation(person, department, params = {})
      GobiertoPeople::Factory.invitation(params.merge(person: person, department: department))
    end

    def create_trip(person, department, params = {})
      GobiertoPeople::Factory.trip(params.merge(person: person, department: department))
    end

    # TODO: improve this tests and remove magic numbers
    def test_query
      query = QueryWithEvents.new(source: site_source)
      assert_equal 25, query.count

      query = QueryWithEvents.new(source: department_source)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: interest_group_source)
      assert_equal 1, query.count

      query = QueryWithEvents.new(source: person_source)
      assert_equal 6, query.count

      query = QueryWithEvents.new(source: site_interest_groups_source)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: site_departments_source)
      assert_equal 5, query.count

      query = QueryWithEvents.new(source: people_with_events_in_department_source)
      assert_equal 2, query.count
    end

    def test_query_with_start_date
      start_date = 1.day.ago

      query = QueryWithEvents.new(source: site_source, start_date: start_date)
      assert_equal 11, query.count

      query = QueryWithEvents.new(source: department_source, start_date: start_date)
      assert_equal 1, query.count

      query = QueryWithEvents.new(source: interest_group_source, start_date: start_date)
      assert_equal 0, query.count

      query = QueryWithEvents.new(source: person_source, start_date: start_date)
      assert_equal 2, query.count

      query = QueryWithEvents.new(source: site_interest_groups_source, start_date: start_date)
      assert_equal 2, query.count

      query = QueryWithEvents.new(source: site_departments_source, start_date: start_date)
      assert_equal 2, query.count

      query = QueryWithEvents.new(source: people_with_events_in_department_source, start_date: start_date)
      assert_equal 2, query.count
    end

    def test_query_with_end_date
      end_date = 1.day.ago

      query = QueryWithEvents.new(source: site_source, end_date: end_date)
      assert_equal 13, query.count

      query = QueryWithEvents.new(source: department_source, end_date: end_date)
      assert_equal 3, query.count

      query = QueryWithEvents.new(source: interest_group_source, end_date: end_date)
      assert_equal 1, query.count

      query = QueryWithEvents.new(source: person_source, end_date: end_date)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: site_interest_groups_source, end_date: end_date)
      assert_equal 2, query.count

      query = QueryWithEvents.new(source: site_departments_source, end_date: end_date)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: people_with_events_in_department_source, end_date: end_date)
      assert_equal 2, query.count
    end

    def test_query_with_start_and_end_dates
      start_date = 5.days.ago
      end_date = 5.days.from_now

      query = QueryWithEvents.new(source: site_source, start_date: start_date, end_date: end_date)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: department_source, start_date: start_date, end_date: end_date)
      assert_equal 0, query.count

      query = QueryWithEvents.new(source: interest_group_source, start_date: start_date, end_date: end_date)
      assert_equal 0, query.count

      query = QueryWithEvents.new(source: person_source, start_date: start_date, end_date: end_date)
      assert_equal 0, query.count

      query = QueryWithEvents.new(source: site_interest_groups_source, start_date: start_date, end_date: end_date)
      assert_equal 0, query.count

      query = QueryWithEvents.new(source: site_departments_source, start_date: start_date, end_date: end_date)
      assert_equal 0, query.count

      query = QueryWithEvents.new(source: people_with_events_in_department_source, start_date: start_date, end_date: end_date)
      assert_equal 0, query.count
    end

    def test_filter_people_filter_by_site
      included_person = create_person("Included person", badajoz)
      create_person("Excluded person", madrid)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_events
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", madrid)
      create_event(person: included_person, department: badajoz_department, site: badajoz)
      create_event(person: excluded_person, department: madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_events_filters_by_dates
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", badajoz)
      create_event(person: included_person, department: badajoz_department, site: badajoz, starts_at: :far_past)
      create_event(person: excluded_person, department: badajoz_department, site: badajoz, starts_at: :future)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: badajoz.people,
        from_date: FAR_PAST,
        to_date: PAST
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_gifts
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", madrid)
      create_gift(included_person, badajoz_department)
      create_gift(excluded_person, madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_gifts_filters_by_dates
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", badajoz)
      create_gift(included_person, badajoz_department, date: PAST)
      create_gift(excluded_person, badajoz_department, date: FUTURE)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: badajoz.people,
        from_date: FAR_PAST,
        to_date: PAST + 2.days
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_trips
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", madrid)
      GobiertoPeople::Factory.trip(person: included_person, department: badajoz_department)
      GobiertoPeople::Factory.trip(person: excluded_person, department: madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_trips_filters_by_dates
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", badajoz)
      create_trip(included_person, badajoz_department, start_date: PAST, end_date: PAST + 1.day)
      create_trip(excluded_person, badajoz_department, start_date: FUTURE, end_date: FUTURE + 1.day)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: badajoz.people,
        from_date: FAR_PAST,
        to_date: PAST + 2.days
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_invitations
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", madrid)
      GobiertoPeople::Factory.invitation(person: included_person, department: badajoz_department)
      GobiertoPeople::Factory.invitation(person: excluded_person, department: madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([included_person], people)
    end

    def test_filter_people_linked_through_invitations_filters_by_dates
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", badajoz)
      create_invitation(included_person, badajoz_department, start_date: PAST, end_date: PAST + 1.day)
      create_invitation(excluded_person, badajoz_department, start_date: FUTURE, end_date: FUTURE + 1.day)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: badajoz.people,
        from_date: FAR_PAST,
        to_date: PAST + 2.days
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_filter_by_department_events
      included_person = create_person("Included department event person", badajoz)
      excluded_person = create_person("Excluded department event person", badajoz)
      create_event(person: included_person, department: ecology_department, site: badajoz)
      create_event(person: excluded_person, department: industry_department, site: badajoz)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        department_id: ecology_department.id
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_filter_by_department_gifts
      included_person = create_person("Included department gift person", badajoz)
      excluded_person = create_person("Excluded department gift person", badajoz)
      create_gift(included_person, ecology_department)
      create_gift(excluded_person, industry_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        department_id: ecology_department.id
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_filter_by_department_invitations
      included_person = create_person("Included department invitation person", badajoz)
      excluded_person = create_person("Excluded department invitation person", badajoz)
      create_invitation(included_person, ecology_department)
      create_invitation(excluded_person, industry_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        department_id: ecology_department.id
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_filter_by_department_trips
      included_person = create_person("Included department trip person", badajoz)
      excluded_person = create_person("Excluded department trip person", badajoz)
      create_trip(included_person, ecology_department)
      create_trip(excluded_person, industry_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        department_id: ecology_department.id
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_by_department_and_dates
      skip
    end

    def test_filter_people_filter_by_interest_group
      included_person = create_person("Included person", badajoz)
      excluded_event_person = create_person("Excluded person", badajoz)
      create_event(person: included_person, interest_group: @bank_interest_group, site: badajoz)
      create_event(person: excluded_event_person, interest_group: @oil_interest_group, site: badajoz)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        interest_group_id: @bank_interest_group.id
      )

      assert array_match([included_person], people)
    end

    def test_filter_people_filter_by_interest_group_and_dates
      included_person = create_person("Included person", badajoz)
      excluded_person = create_person("Excluded person", badajoz)
      create_event(person: included_person, interest_group: @bank_interest_group, site: badajoz, starts_at: :far_past)
      create_event(person: excluded_person, interest_group: @bank_interest_group, site: badajoz, starts_at: :future)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        interest_group_id: @bank_interest_group.id,
        from_date: FAR_PAST,
        to_date: PAST + 2.days
      )

      assert array_match([included_person], people)
    end

  end
end
