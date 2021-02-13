# frozen_string_literal: true

require "test_helper"
require "factories/gobierto_people/factory"

module GobiertoPeople
  class TripsQueryTest < ActiveSupport::TestCase

    attr_accessor(
      :site,
      :department,
      :other_department,
      :other_site,
      :department_trips_query,
      :other_department_trips_query,
      :site_trips_query,
      :other_site_person,
      :other_site_department
    )

    def setup
      super
      Trip.destroy_all

      @site = sites(:madrid)
      @other_site = sites(:santander)

      @department = gobierto_people_departments(:culture_department)
      @other_department = gobierto_people_departments(:tourism_department_very_old)

      @site_trips_query = GobiertoPeople::TripsQuery.new(
        site: @site,
        start_date: date_range_start,
        end_date: date_range_end
      )

      @department_trips_query = GobiertoPeople::TripsQuery.new(
        department: @department,
        start_date: date_range_start,
        end_date: date_range_end
      )

      @other_department_trips_query = GobiertoPeople::TripsQuery.new(
        department: @other_department,
        start_date: date_range_start - 10.years,
        end_date: date_range_end
      )

      @other_site_person = gobierto_people_people(:kali)
      @other_site_department = Factory.department(site: other_site)
    end

    def date_range_start
      1.year.ago
    end

    def date_range_end
      10.days.from_now
    end

    def destination(name)
      { "name" => name, "lat" => 48.8588377, "lon" => 2.2770201, city_name: name, country_code: "ES" }
    end

    def destinations(names)
      { "destinations" => names.map { |name| destination(name) } }
    end

    def test_site_count
      assert site_trips_query.count.zero?

      GobiertoPeople::Factory.trip(site: site)
      GobiertoPeople::Factory.trip(site: site, start_date: date_range_start - 10.years) # Other department
      GobiertoPeople::Factory.trip(site: other_site, person: other_site_person)

      assert_equal 1, site_trips_query.count
    end

    def test_site_unique_destinations_count
      assert site_trips_query.unique_destinations_count.zero?

      GobiertoPeople::Factory.trip(site: site, destinations_meta: destinations(%w(Paris London)))
      GobiertoPeople::Factory.trip(site: site, destinations_meta: destinations(%w(Paris)))
      GobiertoPeople::Factory.trip(site: site, destinations_meta: destinations(%w(London)))
      GobiertoPeople::Factory.trip(site: site, start_date: date_range_start - 10.years, destinations_meta: destinations(%w(Brussels))) # Other department
      GobiertoPeople::Factory.trip(site: other_site, person: other_site_person, destinations_meta: destinations(%w(Madrid)))

      assert_equal 3, site_trips_query.count
      assert_equal 2, site_trips_query.unique_destinations_count
    end

    def test_department_count
      assert department_trips_query.count.zero?

      GobiertoPeople::Factory.trip
      GobiertoPeople::Factory.trip(start_date: date_range_start - 10.years) # Other department
      GobiertoPeople::Factory.trip(site: other_site, person: other_site_person)

      assert_equal 1, department_trips_query.count
      assert_equal 1, other_department_trips_query.count
    end

    def test_department_unique_destinations_count
      assert department_trips_query.unique_destinations_count.zero?

      GobiertoPeople::Factory.trip(destinations_meta: destinations(%w(Paris London)))
      GobiertoPeople::Factory.trip(destinations_meta: destinations(%w(Paris)))
      GobiertoPeople::Factory.trip(start_date: date_range_start - 10.years, destinations_meta: destinations(%w(Brussels))) # Other department
      GobiertoPeople::Factory.trip(person: other_site_person, destinations_meta: destinations(%w(Madrid)))

      assert_equal 2, department_trips_query.unique_destinations_count
      assert_equal 1, other_department_trips_query.unique_destinations_count
    end

  end
end
