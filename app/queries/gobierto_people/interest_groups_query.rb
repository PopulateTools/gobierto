# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupsQuery

    attr_reader :limit, :relation

    DEFAULT_LIMIT = 10

    def initialize(params = {})
      @relation = (params[:relation] || model.all).joins(:events)
      append_query_conditions(params[:conditions]) if params[:conditions]
      @limit = params[:limit] || DEFAULT_LIMIT
    end

    def results
      relation.select("#{model.table_name}.*, COUNT(*) AS events_count")
              .group(:id)
              .order("events_count DESC")
              .limit(limit)
    end

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

    def events_table
      ::GobiertoCalendars::Event.table_name
    end

    def append_condition(attribute_name, attribute_value, operator = "=")
      @relation = relation.where("#{events_table}.#{attribute_name} #{operator} ?", attribute_value)
    end

  end
end
