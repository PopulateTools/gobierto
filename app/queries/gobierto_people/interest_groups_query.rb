# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupsQuery < RowchartItemsQuery

    private

    def append_query_conditions(conditions)
      if conditions[:department_id]
        append_condition(:department_id, conditions[:department_id])
      end

      if conditions[:person_id]
        person = ::GobiertoPeople::Person.find(conditions[:person_id])
        append_condition(:collection_id, person.calendar.id)
      end

      if conditions[:from_date]
        append_condition(:starts_at, conditions[:from_date], ">=")
      end

      if conditions[:to_date]
        append_condition(:ends_at, conditions[:to_date], "<=")
      end
    end

    def model
      InterestGroup
    end

  end
end
