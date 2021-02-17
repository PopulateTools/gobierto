# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class PeopleQueryTest < ActiveSupport::TestCase

    include ::EventHelpers

    attr_accessor(
      :justice_department,
      :coca_cola_interest_group,
      :tamara,
      :richard,
      :site,
      :nelson,
      :neil
    )

    def setup
      super
      @site = sites(:madrid)
      @justice_department = gobierto_people_departments(:justice_department)
      @coca_cola_interest_group = gobierto_people_interest_groups(:coca_cola)
      @tamara = gobierto_people_people(:tamara)
      @richard = gobierto_people_people(:richard)
      @nelson = gobierto_people_people(:nelson)
      @neil = gobierto_people_people(:neil)
    end

    alias person_with_justice_department_events neil
    alias person_with_coca_cola_events tamara
    alias person_with_justice_department_trips richard
    alias person_without_coca_cola_events richard
    alias person_without_justice_department_events nelson

    def test_query
      query_results = PeopleQuery.new(relation: site.people).results

      people_attending_to_events = site.people.where(
        id: ::GobiertoCalendars::EventAttendee.pluck(:person_id)
      )

      assert_equal query_results.length, people_attending_to_events.size

      person = query_results.first

      assert_equal tamara.attending_events.size, person.custom_events_count
    end

    def test_filter_by_department
      query_results = PeopleQuery.new(
        relation: site.people,
        conditions: { department_id: justice_department.id }
      ).results

      assert query_results.include?(person_with_justice_department_events)
      assert query_results.exclude?(person_with_justice_department_trips)
      assert query_results.exclude?(person_without_justice_department_events)
    end

    def test_filter_by_interest_group
      query_results = PeopleQuery.new(
        relation: site.people,
        conditions: { interest_group_id: coca_cola_interest_group.id }
      ).results

      assert query_results.include?(person_with_coca_cola_events)
      assert query_results.exclude?(person_without_coca_cola_events)
    end

    def test_filter_by_date
      ::GobiertoCalendars::EventAttendee.destroy_all
      create_event(person: richard, starts_at: 1.month.ago)
      create_event(person: tamara, starts_at: 1.month.from_now)

      query_results = PeopleQuery.new(
        relation: site.people,
        conditions: { start_date: Time.zone.now }
      ).results

      assert query_results.include?(tamara)
      assert query_results.exclude?(richard)

      query_results = PeopleQuery.new(
        relation: site.people,
        conditions: { end_date: Time.zone.now }
      ).results

      assert query_results.exclude?(tamara)
      assert query_results.include?(richard)
    end

  end
end
