# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class TripTest < ActiveSupport::TestCase

    def trip
      @trip ||= gobierto_people_trips(:richard_multiple_destinations_recent)
    end

    def richard
      @richard ||= gobierto_people_people(:richard)
    end

    def paris
      @paris ||= {
        "lat" => 48.8588377,
        "lon" => 2.2770201,
        "name" => "Paris"
      }
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_destinations
      assert_equal 3, trip.destinations.size

      assert_equal paris, trip.destinations.first
    end

    def test_to_url
      assert_equal "http://#{site.domain}/personas/#{richard.slug}/viajes-y-desplazamientos/#{trip.id}", trip.to_url
    end

  end
end
