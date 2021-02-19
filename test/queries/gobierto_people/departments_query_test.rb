# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class DepartmentsQueryTest < ActiveSupport::TestCase

    def coca_cola
      @coca_cola ||= gobierto_people_interest_groups(:coca_cola)
    end

    def tourism_department
      @tourism_department ||= gobierto_people_departments(:tourism_department_very_old)
    end

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

    def test_filter_by_interest_group
      query = DepartmentsQuery.new(conditions: { interest_group_id: coca_cola.id })

      assert query.results.include?(tourism_department)
    end
  end
end
