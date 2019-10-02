# frozen_string_literal: true

module GobiertoPlans
  module CategoryTermDecoratorTableAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(plan, node)
      super_result = super(plan, node)

      table_records = GobiertoCommon::CustomFieldRecord.where(
        item: node
      ).joins(
        :custom_field
      ).where(
        "custom_fields.options @> ?",
        { configuration: { plugin_type: "table" } }.to_json
      )

      human_resources_condition = { configuration: { plugin_configuration: { category_term_decorator: "human_resources" } } }.to_json
      indicators_condition = { configuration: { plugin_configuration: { category_term_decorator: "indicators" } } }.to_json

      if (human_resources_records = table_records.where("custom_fields.options @> ?", human_resources_condition)).exists?
        super_result[:human_resources] = human_resources_data(human_resources_records, version: node.published_version)
      end

      if (indicators_records = table_records.where("custom_fields.options @> ?", indicators_condition)).exists?
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
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.indicators.title", locale: locale)]
        end],
        data: []
      }
    end

    def human_resources_data_template
      {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.human_resources.title", locale: locale)]
        end],
        budgeted_amount: nil,
        executed_amount: nil,
        executed_percentage: nil
      }
    end

  end
end
