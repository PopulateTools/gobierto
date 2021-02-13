# frozen_string_literal: true

module GobiertoPeople
  class TripsQuery

    attr_reader(
      :start_date,
      :end_date,
      :department,
      :site
    )

    def initialize(params = {})
      @site = params[:site]
      @department = params[:department]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    def count
      base_trips.between_dates(start_date, end_date).count
    end

    def unique_destinations_count
      ActiveRecord::Base.connection.execute(%{
        SELECT COUNT(*) FROM (#{unique_destinations_sql}) AS unique_destinations
      }).first["count"]
    end

    private

    def unique_destinations_sql
      %{
      SELECT DISTINCT
        (destination->>'city_name') AS destination_city_name,
        (destination->>'country_code') AS country_code
      FROM
      ( SELECT
          jsonb_array_elements(destinations_meta->'destinations') as destination
        FROM
        (#{base_trips.between_dates(start_date, end_date).to_sql}) trips_subquery
        ) destinations
      }
    end

    def db_date(date)
      "'#{Trip.sanitize_sql date.to_s(:db)}'"
    end

    def base_trips
      department ? department.trips : site.trips
    end

  end
end
