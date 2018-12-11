# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class QueryWithEventsTest < ActiveSupport::TestCase

    include ::EventHelpers

    def justice_department
      @justice_department ||= gobierto_people_departments(:justice_department)
    end

    def coca_cola_interest_group
      @coca_cola_interest_group ||= gobierto_people_interest_groups(:coca_cola)
    end

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

    def site
      @site || sites(:madrid)
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

    def test_query
      query = QueryWithEvents.new(source: site_source)
      assert_equal 21, query.count

      query = QueryWithEvents.new(source: department_source)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: interest_group_source)
      assert_equal 1, query.count

      query = QueryWithEvents.new(source: person_source)
      assert_equal 6, query.count

      query = QueryWithEvents.new(source: site_interest_groups_source)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: site_departments_source)
      assert_equal 2, query.count

      query = QueryWithEvents.new(source: people_with_events_in_department_source)
      assert_equal 1, query.count
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
      assert_equal 1, query.count
    end

    def test_query_with_end_date
      end_date = 1.day.ago

      query = QueryWithEvents.new(source: site_source, end_date: end_date)
      assert_equal 9, query.count

      query = QueryWithEvents.new(source: department_source, end_date: end_date)
      assert_equal 3, query.count

      query = QueryWithEvents.new(source: interest_group_source, end_date: end_date)
      assert_equal 1, query.count

      query = QueryWithEvents.new(source: person_source, end_date: end_date)
      assert_equal 4, query.count

      query = QueryWithEvents.new(source: site_interest_groups_source, end_date: end_date)
      assert_equal 2, query.count

      query = QueryWithEvents.new(source: site_departments_source, end_date: end_date)
      assert_equal 1, query.count

      query = QueryWithEvents.new(source: people_with_events_in_department_source, end_date: end_date)
      assert_equal 1, query.count
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
  end
end
