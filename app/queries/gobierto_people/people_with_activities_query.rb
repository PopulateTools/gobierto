# frozen_string_literal: true

module GobiertoPeople
  class PeopleWithActivitiesQuery < RowchartItemsQuery

    def initialize(params = {})
      @site = params[:site]
      @conditions = params[:conditions].symbolize_keys
      @relation = (params[:relation] || model).where(id: people_with_activities.map(&:id)).left_outer_joins(events_association)
      append_query_conditions(@conditions) if @conditions
      @limit = params[:limit] || DEFAULT_LIMIT
    end

    def people_with_activities
      GobiertoPeople::Person.find_by_sql(activities_sql)
    end

    private

    def events_association
      :attending_events
    end

    ASSOCIATIONS = {
      events:
      {
        association_name: :attending_events,
        start_date: "#{GobiertoCalendars::Event.table_name}.starts_at >= :start_date",
        end_date: "#{GobiertoCalendars::Event.table_name}.ends_at <= :end_date"
      },
      trips:
      {
        association_name: :trips,
        start_date: "#{GobiertoPeople::Trip.table_name}.start_date >= :start_date",
        end_date: "#{GobiertoPeople::Trip.table_name}.end_date <= :end_date"
      },
      invitations:
      {
        association_name: :invitations,
        start_date: "#{GobiertoPeople::Invitation.table_name}.start_date >= :start_date",
        end_date: "#{GobiertoPeople::Invitation.table_name}.end_date <= :end_date"
      },
      gifts:
      {
        association_name: :received_gifts,
        start_date: "#{GobiertoPeople::Gift.table_name}.date >= :start_date",
        end_date: "#{GobiertoPeople::Gift.table_name}.date <= :end_date"
      }
    }.freeze

    def model
      Person
    end

    def append_query_conditions(conditions)
      if conditions[:department_id]
        @relation = Department.filter_department_people(
          conditions.slice(:department_id, :start_date, :end_date)
          .merge(people_relation: relation)
        )
      end

      if conditions[:interest_group_id]
        append_condition(:interest_group_id, conditions[:interest_group_id])
      end

      if conditions[:start_date]
        append_condition(:starts_at, conditions[:start_date], ">=", true)
      end

      if conditions[:end_date]
        append_condition(:ends_at, conditions[:end_date], "<=", true)
      end
    end

    def table_name
      model.table_name
    end

    def activities_sql
      # Query to find people from a people relation or the model itself which
      # have at least one activity within the dates set in @conditions and are of
      # one of the types defined in ASSOCIATIONS

      # This sql is used to provide common table expresions selecting all kinds
      # of person activities restricted to the dates in @conditions
      common_table_expression = ASSOCIATIONS.keys.map do |association_model|
        "#{association_model}_relation AS (#{relation_sql(association_model)})"
      end.join(", ")

      # left outer joins of all previous common table expressions with relation table
      joins = ASSOCIATIONS.keys.map do |association_model|
        "LEFT OUTER JOIN #{association_model}_relation on #{table_name}.id = #{association_model}_relation.id"
      end.join(" ")

      # the person must be present in at least one of the previous common table
      # expression
      where = ASSOCIATIONS.keys.map do |association_model|
        "#{table_name}.id = #{association_model}_relation.id"
      end.join(" OR ")

      "WITH #{common_table_expression} SELECT DISTINCT(#{table_name}.id) FROM #{table_name} #{joins} WHERE #{where}"
    end

    def relation_sql(model)
      # sql of join between people and model restricted to the the date range of @conditions
      @site.people.joins(ASSOCIATIONS[model][:association_name]).where(date_range_sql(model, @conditions), @conditions).distinct.to_sql
    end

    def date_range_sql(model, conditions = {})
      date_params = conditions.slice(:start_date, :end_date).compact

      ASSOCIATIONS[model].slice(*date_params.keys).values.join(" AND ")
    end
  end
end
