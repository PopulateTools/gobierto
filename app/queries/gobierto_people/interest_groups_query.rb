# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupsQuery

    attr_reader :conditions, :limit, :relation

    DEFAULT_LIMIT = 10

    def initialize(params = {})
      @conditions = (params[:conditions] || {}).slice!(permitted_conditions)
      parse_conditions!
      @limit = params[:limit] || DEFAULT_LIMIT
      @relation = params[:relation] || model.all
    end

    def results
      query_scope = conditions.any? ? relation.where(conditions) : relation

      query_scope.joins(:events)
                 .select("#{model.table_name}.*, COUNT(*) AS events_count")
                 .group(:id)
                 .order("events_count DESC")
                 .limit(limit)
    end

    private

    def permitted_conditions
      [:department_id, :person_id]
    end

    def parse_conditions!
      if conditions[:department_id]
        process_condition(
          :department_id,
          events_scope.where(department_id: conditions[:department_id])
        )
      end

      if conditions[:person_id]
        person = ::GobiertoPeople::Person.find(conditions[:person_id])
        process_condition(:person_id, person.events.with_interest_group)
      end

      if conditions[:from_date]
        process_condition(
          :from_date,
          events_scope.where("starts_at >= ?", conditions[:from_date])
        )
      end

      if conditions[:to_date]
        process_condition(
          :to_date,
          events_scope.where("ends_at <= ?", conditions[:to_date])
        )
      end
    end

    def events_scope
      ::GobiertoCalendars::Event.with_interest_group
    end

    def model
      InterestGroup
    end

    def process_condition(condition, interest_groups_scope)
      conditions.delete(condition)
      if conditions[:id]
        conditions[:id] += interest_groups_scope.pluck(:interest_group_id)
      else
        conditions[:id] = interest_groups_scope.pluck(:interest_group_id)
      end
    end

  end
end
