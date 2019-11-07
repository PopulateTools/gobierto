# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class PluginTest < ActiveSupport::TestCase

    def record
      gobierto_common_custom_field_records(:political_agendas_indicators_table_custom_field_record)
    end

    def test_value
      assert_equal(
        [
          { "date" => "2018-12", "indicator" => 162_407_219, "objective" => 100, "value_reached" => 92.5 },
          { "date" => "2018-11", "indicator" => 162_407_219, "objective" => 100, "value_reached" => 85 },
          { "date" => "2019", "indicator" => 488_958_338, "objective" => 200, "value_reached" => 210 },
          { "indicator" => 142_661_490, "objective" => 50 },
          { "indicator" => 428_155_164 }
        ],
        record.value
      )
    end

    def test_assign_value
      new_payload_hash = [{ "date" => "2018", "indicator" => 1, "objective" => 2, "value_reached" => 3 }]

      record.value = new_payload_hash

      assert_equal new_payload_hash, record.payload

      new_payload_json = "[{\"date\":\"2018\",\"indicator\":1,\"objective\":2,\"value_reached\":3}]"
      record.value = new_payload_json

      assert_equal new_payload_hash, record.payload
    end

  end
end
