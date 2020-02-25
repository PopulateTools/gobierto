# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"
require "factories/common_factory"
require "factories/gobierto_people/factory"

module GobiertoPeople
  class QueryWithEventsTest < ActiveSupport::TestCase

    include ::EventHelpers

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

    def create_included_person
      @included_person = GobiertoPeople::Factory.person(name: "Included person", site: badajoz)
    end

    def create_excluded_madrid_person
      @excluded_madrid_person = GobiertoPeople::Factory.person(name: "Excluded person", site: madrid)
    end

    def create_gift(person, department)
      GobiertoPeople::Factory.gift(person: person, department: department)
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
      skip
    end

    def test_filter_people_linked_through_events
      create_included_person
      create_excluded_madrid_person
      create_event(person: @included_person, department: badajoz_department, site: badajoz)
      create_event(person: @excluded_madrid_person, department: madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([@included_person], people)
    end

    def test_filter_people_linked_through_events_filters_by_dates
      skip
    end

    def test_filter_people_linked_through_gifts
      create_included_person
      create_excluded_madrid_person
      create_gift(@included_person, badajoz_department)
      create_gift(@excluded_madrid_person, madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([@included_person], people)
    end

    def test_filter_people_linked_through_gifts_filters_by_dates
      skip
    end

    def test_filter_people_linked_through_trips
      create_included_person
      create_excluded_madrid_person
      GobiertoPeople::Factory.trip(person: @included_person, department: badajoz_department)
      GobiertoPeople::Factory.trip(person: @excluded_madrid_person, department: madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([@included_person], people)
    end

    def test_filter_people_linked_through_trips_filters_by_dates
      skip
    end

    def test_filter_people_linked_through_invitations
      create_included_person
      create_excluded_madrid_person
      GobiertoPeople::Factory.invitation(person: @included_person, department: badajoz_department)
      GobiertoPeople::Factory.invitation(person: @excluded_madrid_person, department: madrid_department)

      people = GobiertoPeople::QueryWithEvents.filter_people(people_relation: badajoz.people)

      assert array_match([@included_person], people)
    end

    def test_filter_people_linked_through_invitations_filters_by_dates
      skip
    end

    def test_filter_people_filter_by_department
      # setup
      included_department_event_person = GobiertoPeople::Factory.person(name: "Included department event person", site: badajoz)
      excluded_department_event_person = GobiertoPeople::Factory.person(name: "Excluded department event person", site: badajoz)

      included_department_gift_person = GobiertoPeople::Factory.person(name: "Included department gift person", site: badajoz)
      excluded_department_gift_person = GobiertoPeople::Factory.person(name: "Excluded department gift person", site: badajoz)

      included_department_invitation_person = GobiertoPeople::Factory.person(name: "Included department invitation person", site: badajoz)
      excluded_department_invitation_person = GobiertoPeople::Factory.person(name: "Excluded department invitation person", site: badajoz)

      included_department_trip_person = GobiertoPeople::Factory.person(name: "Included department trip person", site: badajoz)
      excluded_department_trip_person = GobiertoPeople::Factory.person(name: "Excluded department trip person", site: badajoz)

      create_event(person: included_department_event_person, department: ecology_department, site: badajoz)
      create_event(person: excluded_department_event_person, department: industry_department, site: badajoz)

      create_gift(included_department_gift_person, ecology_department)
      create_gift(excluded_department_gift_person, industry_department)

      GobiertoPeople::Factory.invitation(person: included_department_invitation_person, department: ecology_department)
      GobiertoPeople::Factory.invitation(person: excluded_department_invitation_person, department: industry_department)

      GobiertoPeople::Factory.trip(person: included_department_trip_person, department: ecology_department)
      GobiertoPeople::Factory.trip(person: excluded_department_trip_person, department: industry_department)

      # execution
      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        department_id: ecology_department.id
      )

      # assertions
      expected_people = [included_department_event_person, included_department_gift_person, included_department_invitation_person, included_department_trip_person]
      assert array_match(expected_people, people)
    end

    def test_filter_people_by_department_and_dates
      skip
    end

    def test_filter_people_filter_by_interest_group
      included_event_person = create_included_person
      excluded_event_person = GobiertoPeople::Factory.person(name: "Excluded person", site: badajoz)
      create_event(person: included_event_person, interest_group: @bank_interest_group, site: badajoz)
      create_event(person: excluded_event_person, interest_group: @oil_interest_group, site: badajoz)

      people = GobiertoPeople::QueryWithEvents.filter_people(
        people_relation: GobiertoPeople::Person.all,
        interest_group_id: @bank_interest_group.id
      )

      assert array_match([included_event_person], people)
    end

    def test_filter_people_filter_by_interest_group_and_dates
      skip
    end

  end
end
