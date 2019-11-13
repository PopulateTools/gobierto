# frozen_string_literal: true

module GobiertoPlans
  module CategoryTermDecoratorTableAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(plan, node)
      super_result = super(plan, node)

      indicators_records = get_indicators_records(node)
      human_resources_records = get_human_resources_records(node)

      if human_resources_records.exists?
        super_result[:human_resources] = human_resources_data(human_resources_records, version: node.published_version)
      end

      if indicators_records.exists?
        super_result[:indicators] = indicators_data(indicators_records, version: node.published_version)
      end

      super_result
    end

    def human_resources_data(records, version: nil)
      totals = human_resources_data_template

      if records.present?
        functions = records.map do |record|
          GobiertoCommon::CustomFieldFunctions::HumanResource.new(record, version: version)
        end

        total_cost = functions.map(&:planned_cost).compact.sum
        total_executed = functions.map(&:executed_cost).compact.sum

        totals[:budgeted_amount] = total_cost.round
        totals[:executed_amount] = total_executed.round
        if total_cost.positive?
          totals[:executed_percentage] = "#{((total_executed * 100) / total_cost).round} %"
        end
      end

      totals
    end

    def indicators_data(records, version: nil)
      totals = indicators_data_template

      if records.present?
        combined_table = records.map do |record|
          ::GobiertoCommon::CustomFieldFunctions::Indicator.new(record, version: version).indicators
        end.flatten

        totals[:data] = ::GobiertoCommon::CustomFieldFunctions::Indicator.latest_indicators(combined_table).map do |row|
          { id: row.id,
            name_translations: row.indicator.name_translations,
            description_translations: row.indicator.description_translations,
            last_value: row.value_reached,
            date: row.date_string }
        end
      end

      totals
    end

    def indicators_data_template
      {
        title_translations: indicators_custom_fields&.first&.name_translations,
        data: []
      }
    end

    def human_resources_data_template
      {
        title_translations: human_resources_custom_fields&.first&.name_translations,
        budgeted_amount: nil,
        executed_amount: nil,
        executed_percentage: nil
      }
    end

    def get_indicators_records(node)
      ::GobiertoCommon::CustomFieldRecord.where(custom_field: indicators_custom_fields, item: node)
    end

    def get_human_resources_records(node)
      ::GobiertoCommon::CustomFieldRecord.where(custom_field: human_resources_custom_fields, item: node)
    end

    def indicators_custom_fields
      @indicators_custom_fields ||= site.custom_fields.where("options @> ?", { configuration: {
        plugin_type: "table",
        plugin_configuration: { category_term_decorator: "indicators" }
      }}.to_json)
    end

    def human_resources_custom_fields
      @human_resources_custom_fields ||= site.custom_fields.where("options @> ?", { configuration: {
        plugin_type: "table",
        plugin_configuration: { category_term_decorator: "human_resources" }
      }}.to_json)
    end

  end
end
