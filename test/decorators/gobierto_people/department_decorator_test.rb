# frozen_string_literal: true

require "test_helper"
require "factories/gobierto_people/factory"

module GobiertoPeople
  class DepartmentDecoratorTest < ActiveSupport::TestCase

    attr_accessor(
      :department,
      :decorator,
      :other_department
    )

    def setup
      super
      Trip.destroy_all

      @department = gobierto_people_departments(:culture_department)
      @other_department = gobierto_people_departments(:justice_department)
      @decorator = DepartmentDecorator.new(department, {
        filter_start_date: date_range_start,
        filter_end_date: date_range_end
      })
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

    def test_trips_count
      assert decorator.trips_count.zero?

      GobiertoPeople::Factory.trip(department: department)
      GobiertoPeople::Factory.trip(department: department)
      GobiertoPeople::Factory.trip(department: department, start_date: date_range_start - 10.years)

      assert_equal 2, decorator.trips_count
    end

    def test_unique_destinations_count
      assert decorator.trips_unique_destinations_count.zero?

      GobiertoPeople::Factory.trip(department: department, destinations_meta: destinations(%w(Paris London)))
      GobiertoPeople::Factory.trip(department: department, destinations_meta: destinations(%w(Paris)))

      assert_equal 2, decorator.trips_unique_destinations_count
    end

    def test_unique_destinations_count_when_out_of_range
      GobiertoPeople::Factory.trip(department: department, destinations_meta: destinations(%w(Paris)))
      GobiertoPeople::Factory.trip(department: department, start_date: 10.years.ago, destinations_meta: destinations(%w(Amsterdam)))

      assert_equal 1, decorator.trips_unique_destinations_count
    end

    def test_unique_destinations_count_when_other_department
      GobiertoPeople::Factory.trip(department: department, destinations_meta: destinations(%w(Paris)))
      GobiertoPeople::Factory.trip(department: other_department, destinations_meta: destinations(%w(Amsterdam)))

      assert_equal 1, decorator.trips_unique_destinations_count
    end

  end
end
