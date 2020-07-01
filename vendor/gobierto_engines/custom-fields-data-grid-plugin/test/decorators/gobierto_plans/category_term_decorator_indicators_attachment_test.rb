# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTermDecoratorIndicatorsAttachmentTest < ActiveSupport::TestCase

    def decorator
      GobiertoPlans::CategoryTermDecorator.new(
        gobierto_common_terms(:center_basic_needs_plan_term)
      )
    end

    def raw_plugin_data
      decorator.nodes_data.first[:attributes][:plugins_data][:raw_indicators]
    end

    def custom_field
      gobierto_common_custom_fields(:madrid_custom_field_indicators_table_plugin)
    end

    def plugin_data
      custom_field_options = custom_field.options
      custom_field_options["configuration"]["plugin_configuration"]["category_term_decorator"] = "indicators"
      custom_field.update_attribute(:options, custom_field_options)
      decorator.nodes_data.first[:attributes][:plugins_data][:indicators]
    end

    def expected_indicator_raw_attributes
      {
        id: 162_407_219,
        name: "Raw savings",
        description: "Description of raw savings",
        objective: 100,
        value: 92.5,
        date: "2018-12"
      }
    end

    def expected_indicator_attributes
      {
        id: 162_407_219,
        name_translations: {
          "en" => "Raw savings",
          "es" => "Ahorro bruto"
        },
        description_translations: {
          "en" => "Description of raw savings",
          "es" => "Descripción de ahorro bruto"
        },
        last_value: 92.5,
        date: "2018-12"
      }
    end

    def test_raw_plugin_data
      assert_equal "Indicator (table)", raw_plugin_data[:title_translations]["en"]
      assert_equal 5, raw_plugin_data[:data].size
      assert_equal expected_indicator_raw_attributes, raw_plugin_data[:data].first
    end

    def test_plugin_data
      assert_equal "Indicator (table)", plugin_data[:title_translations]["en"]
      assert_equal 2, plugin_data[:data].size
      assert_equal expected_indicator_attributes, plugin_data[:data].first
    end

  end
end
