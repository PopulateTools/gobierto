# frozen_string_literal: true

module GobiertoPeople
  class PeopleQuery < RowchartItemsQuery

    private

    def append_query_conditions(conditions)
      if conditions[:department_id]
        @relation = Department.filter_department_people(relation, conditions[:department_id])
      end

      if conditions[:interest_group_id]
        append_condition(:interest_group_id, conditions[:interest_group_id])
      end

      if conditions[:from_date]
        append_condition(:starts_at, conditions[:from_date], ">=")
      end

      if conditions[:to_date]
        append_condition(:ends_at, conditions[:to_date], "<=")
      end
    end

    def model
      Person
    end

    def events_association
      :attending_events
    end

  end
end
