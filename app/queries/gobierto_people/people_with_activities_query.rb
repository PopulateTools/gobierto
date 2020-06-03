# frozen_string_literal: true

module GobiertoPeople
  class PeopleWithActivitiesQuery < RowchartItemsQuery

    def initialize(params = {})
      @site = params[:site]
      @conditions = params[:conditions].symbolize_keys
      @relation = (params[:relation] || model.all).where(id: people_with_activities.map(&:id)).left_outer_joins(events_association)
      append_query_conditions(@conditions) if @conditions
      @limit = params[:limit] || DEFAULT_LIMIT
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

    def people_with_activities
      GobiertoPeople::Person.find_by_sql(activities_sql)
    end

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
      cte = ASSOCIATIONS.keys.map do |association_model|
        "#{association_model}_relation AS (#{relation_sql(association_model)})"
      end.join(", ")

      joins = ASSOCIATIONS.keys.map do |association_model|
        "LEFT OUTER JOIN #{association_model}_relation on #{table_name}.id = #{association_model}_relation.id"
      end.join(" ")

      where = ASSOCIATIONS.keys.map do |association_model|
        "#{table_name}.id = #{association_model}_relation.id"
      end.join(" OR ")

      "WITH #{cte} SELECT DISTINCT(#{table_name}.*) FROM #{table_name} #{joins} WHERE #{where}"
    end

    def relation_sql(model)
      @site.people.joins(ASSOCIATIONS[model][:association_name]).where(date_range_sql(model, @conditions), @conditions).distinct.to_sql
    end

    def date_range_sql(model, conditions = {})
      date_params = conditions.slice(:start_date, :end_date).compact

      ASSOCIATIONS[model].slice(*date_params.keys).values.join(" AND ")
    end
  end
end
