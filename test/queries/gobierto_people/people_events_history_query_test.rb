# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class PeopleEventsHistoryQueryTest < ActiveSupport::TestCase

    include ::EventHelpers

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

    def richard
      @richard ||= gobierto_people_people(:richard)
    end

    def site
      @site || sites(:madrid)
    end

    def people_scope
      site.people.where(id: [richard.id, tamara.id])
    end

    def setup
      richard.attending_events.destroy_all
      tamara.attending_events.destroy_all

      @all_events = [
        create_event(person: richard, starts_at: "15-01-2017"),
        create_event(person: tamara, starts_at: "15-01-2017"),
        create_event(person: tamara, starts_at: "16-01-2017"),
        create_event(person: tamara, starts_at: "15-02-2017"),
        create_event(person: tamara, starts_at: "15-01-2018")
      ]
    end

    def test_query
      query_results = PeopleEventsHistoryQuery.new(relation: people_scope).results

      assert array_match(people_scope, query_results.uniq)

      tamara_results = query_results.select { |record| record == tamara }.map do |record|
        { date: record.year_month, count: record.custom_events_count }
      end

      assert_equal 3, tamara_results.size

      expected_results = [
        { date: "2017/01", count: 2 },
        { date: "2017/02", count: 1 },
        { date: "2018/01", count: 1 }
      ]

      assert array_match expected_results, tamara_results
    end

  end
end
