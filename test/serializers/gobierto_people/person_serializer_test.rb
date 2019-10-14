# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class RowchartItemSerializerTest < ActiveSupport::TestCase

    attr_accessor :person

    def setup
      super
      @person = gobierto_people_people(:richard)
    end

    def test_serialize
      serializer = PersonSerializer.new(person)
      serializer_output = JSON.parse(serializer.to_json)

      assert_equal person.name, serializer_output["name"]
      assert_equal person.charge, serializer_output["charge"]
      assert_equal "http://madrid.gobierto.test/personas/richard-rider", serializer_output["url"]
    end

    def test_serialize_with_date_range
      serializer = PersonSerializer.new(person, date_range_query: "start_date=2018-06-01")
      serializer_output = JSON.parse(serializer.to_json)

      assert serializer_output["url"].include?("start_date=2018-06-01")
    end

  end
end
