# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class InterestGroupRowchartSerializerTest < ActiveSupport::TestCase

    def madrid
      @madrid ||= sites(:madrid)
    end

    def interest_group
      @interest_group ||= gobierto_people_interest_groups(:google)
    end

    def interest_group_attributes
      %w(key value properties)
    end

    def serializer
      InterestGroupRowchartSerializer.new(interest_group)
    end

    def test_serialize
      serializer_output = JSON.parse(serializer.to_json)

      assert_equal "Google", serializer_output["key"]
      assert_equal 1, serializer_output["value"]
      assert_equal "http://#{madrid.domain}/grupos-de-interes/#{interest_group.slug}", serializer_output["properties"]["url"]
    end

  end
end
