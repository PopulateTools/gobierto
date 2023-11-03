# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  class LocationTest < ActiveSupport::TestCase
    def geocoder_response
      @geocoder_response ||= OpenStruct.new(
        "place_id" => "place1",
        "latitude" => 42.2073223,
        "longitude" => -8.170119999999999,
        "city" => "Cortegada",
        "country_code" => "ES",
        "country" => "Spain",
        "types" => ["locality", "political"]
      )
    end

    def geocoder_other_response
      @geocoder_other_response ||= OpenStruct.new(
        "place_id" => "place2",
        "latitude" => 42.288847,
        "longitude" => -8.1420491,
        "city" => "Ribadavia",
        "country_code" => "ES",
        "country" => "Spain",
        "types" => ["locality", "political"]
      )
    end

    def geocoder_unregistered_response
      @geocoder_unregistered_response ||= OpenStruct.new(
        "place_id" => "place3",
        "latitude" => 36.1900204,
        "longitude" => -5.9224799,
        "city" => "Barbate",
        "country_code" => "ES",
        "country" => "Spain",
        "types" => ["locality", "political"]
      )
    end

    def location_with_external_id
      gobierto_common_locations(:cortegada)
    end

    def location_without_external_id
      gobierto_common_locations(:ribadavia)
    end

    def subject
      ::GobiertoCommon::Location
    end

    def test_search_already_existing_location_by_name
      Geocoder.expects(:search).never

      assert_no_difference "::GobiertoCommon::Location.count" do
        result = subject.search("Cortegada, Ourense")

        assert_equal result, location_with_external_id
      end
    end

    def test_search_already_existing_location_by_other_name
      Geocoder.expects(:search).with("test").returns([geocoder_response]).once

      refute_includes location_with_external_id.names, "test"

      assert_no_difference "::GobiertoCommon::Location.count" do
        subject.search("test")
      end

      location_with_external_id.reload
      assert_includes location_with_external_id.names, "test"
      assert_equal location_with_external_id.external_id, "place1"
      assert_equal location_with_external_id.lat, geocoder_response.latitude
      assert_equal location_with_external_id.lon, geocoder_response.longitude
      assert_equal location_with_external_id.city_name, geocoder_response.city
      assert_equal location_with_external_id.types, geocoder_response.types
    end

    def test_search_already_existing_location_without_external_id_by_other_name
      Geocoder.expects(:search).with("test").returns([geocoder_other_response]).once

      refute_includes location_without_external_id.names, "test"

      assert_no_difference "::GobiertoCommon::Location.count" do
        subject.search("test")
      end

      location_without_external_id.reload
      assert_includes location_without_external_id.names, "test"
      assert_equal location_without_external_id.external_id, "place2"
      assert_equal location_without_external_id.lat, geocoder_other_response.latitude
      assert_equal location_without_external_id.lon, geocoder_other_response.longitude
      assert_equal location_without_external_id.city_name, geocoder_other_response.city
      assert_equal location_without_external_id.types, geocoder_other_response.types
    end

    def test_search_unregistered_data
      Geocoder.expects(:search).with("test").returns([geocoder_unregistered_response]).once

      assert_difference "::GobiertoCommon::Location.count", 1 do
        subject.search("test")
      end

      location = subject.last

      assert_equal geocoder_unregistered_response.place_id, location.external_id
      assert_includes location.names, "test"
    end
  end
end
