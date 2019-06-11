# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class PluginTest < ActiveSupport::TestCase

    def record
      gobierto_common_custom_field_records(:political_agendas_indicators_custom_field_record)
    end

    def test_value
      assert_equal(
        {
          "162407219" => {
            "2018-12" => 5,
            "2019-01" => 10,
            "2019-02" => 15
          },
          "488958338" => {
            "2018-12" => 50.1,
            "2019-01" => 100.2,
            "2019-02" => 150.3
          }
        },
        record.value
      )
    end

    def test_assign_value
      new_payload_hash = { "123" => { "2018-12" => 123.456 } }
      record.value = new_payload_hash

      assert_equal new_payload_hash, record.payload

      new_payload_json = "{\"123\":{\"2018-12\":123.456}}"
      record.value = new_payload_json

      assert_equal new_payload_hash, record.payload
    end

  end
end
