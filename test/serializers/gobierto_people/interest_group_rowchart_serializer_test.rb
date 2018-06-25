# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class RowchartItemSerializerTest < ActiveSupport::TestCase

    def madrid
      @madrid ||= sites(:madrid)
    end

    def interest_group
      @interest_group ||= gobierto_people_interest_groups(:google)
    end

    def interest_group_with_custom_attribute
      ::GobiertoPeople::InterestGroup.where(id: interest_group.id).select("*, 123 AS custom_events_count").first
    end

    def interest_group_attributes
      %w(key value properties)
    end

    def serializer
      RowchartItemSerializer.new(interest_group_with_custom_attribute)
    end

    def test_serialize
      serializer_output = JSON.parse(serializer.to_json)

      assert_equal "Google", serializer_output["key"]
      assert_equal 123, serializer_output["value"]
      assert_equal "http://#{madrid.domain}/grupos-de-interes/#{interest_group.slug}", serializer_output["properties"]["url"]
    end

  end
end
