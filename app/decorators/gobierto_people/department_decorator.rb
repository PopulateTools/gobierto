# frozen_string_literal: true

module GobiertoPeople
  class DepartmentDecorator < BaseDecorator

    attr_accessor(
      :object,
      :filter_start_date,
      :filter_end_date
    )

    def initialize(object, params = {})
      @object = object
      @filter_start_date = params[:filter_start_date]
      @filter_end_date = params[:filter_end_date]
    end

    def gifts
      @gifts ||= site.gifts
                     .where(person_id: people.pluck(:id))
                     .between_dates(filter_start_date, filter_end_date)
                     .limit(4)
    end

    def invitations
      @invitations ||= site.invitations
                           .where(person_id: people.pluck(:id))
                           .between_dates(filter_start_date, filter_end_date)
                           .limit(4)
    end

    def people
      @people ||= QueryWithEvents.new(
        source: object.people.active.with_event_attendances(site),
        start_date: filter_start_date,
        end_date: filter_end_date
      )
    end

    def meetings
      @meetings ||= QueryWithEvents.new(
        source: object.events.published,
        start_date: filter_start_date,
        end_date: filter_end_date
      )
    end

    def stats
      {
        total_people_with_attendances: people.count,
        total_meetings: meetings.count,
        unique_interest_groups: meetings.select(:interest_group_id).distinct.count
      }
    end

    def trips_count
      trips.between_dates(filter_start_date, filter_end_date).count
    end

    def trips_unique_destinations_count
      ActiveRecord::Base.connection.execute(%{
        SELECT COUNT(*) FROM (#{unique_destinations_sql}) AS unique_destinations
      }).first["count"]
    end

    private

    def unique_destinations_sql
      %{
SELECT
  DISTINCT
  (destination->>'city_name') AS destination_city_name,
  (destination->>'country_code') AS country_code
FROM
  #{Trip.table_name}, jsonb_array_elements(destinations_meta->'destinations') destination
WHERE
  #{date_range_scope_sql}
  (destination->>'city_name') IS NOT NULL AND
  department_id = #{id}
      }
    end

    def date_range_scope_sql
      if filter_start_date && filter_end_date
        "start_date >= #{db_date(filter_start_date)} AND end_date <= #{db_date(filter_end_date)} AND"
      elsif filter_start_date
        "start_date >= #{db_date(filter_start_date)} AND"
      elsif end_date
        "end_date <= #{db_date(filter_end_date)} AND"
      end
    end

    def db_date(date)
      "'#{Trip.sanitize_sql date.to_s(:db)}'"
    end

  end
end
