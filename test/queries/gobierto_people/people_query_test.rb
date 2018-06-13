# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class PeopleQueryTest < ActiveSupport::TestCase

    include ::EventHelpers

    def justice_department
      @justice_department ||= gobierto_people_departments(:justice_department)
    end

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end
    alias person_with_justice_department_events tamara

    def richard
      @richard ||= gobierto_people_people(:richard)
    end
    alias person_without_justice_department_events richard

    def site
      @site || sites(:madrid)
    end

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
      assert query_results.exclude?(person_without_justice_department_events)
    end

    def test_filter_by_date
      ::GobiertoCalendars::EventAttendee.destroy_all
      create_event(person: richard, starts_at: 1.month.ago)
      create_event(person: tamara, starts_at: 1.month.from_now)

      query_results = PeopleQuery.new(
        relation: site.people,
        conditions: { from_date: Time.zone.now }
      ).results

      assert query_results.include?(tamara)
      assert query_results.exclude?(richard)

      query_results = PeopleQuery.new(
        relation: site.people,
        conditions: { to_date: Time.zone.now }
      ).results

      assert query_results.exclude?(tamara)
      assert query_results.include?(richard)
    end

  end
end
