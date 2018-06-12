# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class InterestGroupsQueryTest < ActiveSupport::TestCase

    def coca_cola
      @coca_cola ||= gobierto_people_interest_groups(:coca_cola)
    end
    alias justice_department_interest_group coca_cola
    alias tamara_interest_group coca_cola
    alias interest_group_with_recent_event coca_cola
    alias tamara_interst_group_with_recent_event coca_cola

    def google
      @google ||= gobierto_people_interest_groups(:google)
    end
    alias culture_department_interest_group google
    alias richard_interest_group google

    def pepsi
      @pepsi ||= gobierto_people_interest_groups(:pepsi)
    end
    alias interest_group_with_old_event pepsi
    alias tamara_interst_group_with_old_event pepsi

    def justice_department
      @justice_department ||= gobierto_people_departments(:justice_department)
    end

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

    def test_filter_by_department
      query = InterestGroupsQuery.new(conditions: {
        department_id: justice_department.id
      })

      assert query.results.include?(justice_department_interest_group)
      assert query.results.exclude?(culture_department_interest_group)
    end

    def test_filter_by_person
      query = InterestGroupsQuery.new(conditions: {
        person_id: tamara.id
      })

      assert query.results.include?(tamara_interest_group)
      assert query.results.exclude?(richard_interest_group)
    end

    def test_filter_by_date
      query = InterestGroupsQuery.new(conditions: {
        from_date: 2.months.ago
      })

      assert query.results.include?(interest_group_with_recent_event)
      assert query.results.exclude?(interest_group_with_old_event)

      query = InterestGroupsQuery.new(conditions: {
        to_date: 1.year.ago
      })

      assert query.results.include?(interest_group_with_old_event)
      assert query.results.exclude?(interest_group_with_recent_event)
    end

    def test_filter_by_multiple_conditions
      query = InterestGroupsQuery.new(conditions: {
        person_id: tamara.id,
        from_date: 2.months.ago.iso8601
      })

      assert query.results.include?(tamara_interst_group_with_recent_event)
      assert query.results.exclude?(tamara_interst_group_with_old_event)
    end

    def test_limit
      query = InterestGroupsQuery.new(limit: 1)

      assert_equal 1, query.results.length
    end

    def test_order
      query = InterestGroupsQuery.new(conditions: {
        person_id: tamara.id
      })

      # pepsi has 2 events, coca_cola has 1
      assert_equal [pepsi, coca_cola], query.results
    end

  end
end
