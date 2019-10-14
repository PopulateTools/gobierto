# frozen_string_literal: true

module GobiertoPeople
  class TripsQuery

    attr_reader :start_date, :end_date, :department

    def initialize(params = {})
      @department = params[:department]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    def count
      department.trips.between_dates(start_date, end_date).count
    end

    def unique_destinations_count
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
  department_id = #{department.id}
      }
    end

    def date_range_scope_sql
      if start_date && end_date
        "start_date >= #{db_date(start_date)} AND end_date <= #{db_date(end_date)} AND"
      elsif start_date
        "start_date >= #{db_date(start_date)} AND"
      elsif end_date
        "end_date <= #{db_date(end_date)} AND"
      end
    end

    def db_date(date)
      "'#{Trip.sanitize_sql date.to_s(:db)}'"
    end

  end
end
