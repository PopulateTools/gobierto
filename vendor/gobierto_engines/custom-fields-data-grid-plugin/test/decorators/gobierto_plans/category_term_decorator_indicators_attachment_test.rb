# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTermDecoratorIndicatorsAttachmentTest < ActiveSupport::TestCase

    def decorator
      GobiertoPlans::CategoryTermDecorator.new(
        gobierto_common_terms(:center_basic_needs_plan_term)
      )
    end

    def plugin_data
      decorator.nodes_data.first[:attributes][:plugins_data][:indicators]
    end

    def expected_indicator_attributes
      {
        id: 162407219,
        name_translations: {
          "en" => "Raw savings",
          "es" => "Ahorro bruto"
        },
        description_translations: {
          "en" => "Description of raw savings",
          "es" => "Descripción de ahorro bruto"
        },
        last_value: 15,
        values: {
          "2018-12" => 5,
          "2019-01" => 10,
          "2019-02" => 15
        }
      }
    end

    def test_plugin_data
      assert_equal "Indicators", plugin_data[:title_translations][:en]
      assert_equal 2, plugin_data[:data].size
      assert_equal expected_indicator_attributes, plugin_data[:data].first
    end

  end
end
