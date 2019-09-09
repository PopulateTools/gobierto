# frozen_string_literal: true

module GobiertoPlans
  module CategoryTermDecoratorIndicatorsAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(plan, node)
      super_result = super(plan, node)

      super_result[:indicators] = indicators_template
      indicators_fields = site.custom_fields.where(
        "options @> ?",
        { configuration: { plugin_type: "indicators" } }.to_json
      )
      records = ::GobiertoPlans::Node.node_custom_field_records(plan, node).where(custom_field: indicators_fields)

      combined_table = records.map do |record|
        ::GobiertoCommon::CustomFieldFunctions::Indicator.new(record, version: node.published_version).indicators
      end.flatten

      super_result[:indicators][:data] = ::GobiertoCommon::CustomFieldFunctions::Indicator.latest_indicators(combined_table).map do |row|
        { id: row.id,
          name_translations: row.indicator.name_translations,
          description_translations: row.indicator.description_translations,
          last_value: row.value_reached,
          date: row.date_string }
      end

      super_result
    end

    def indicators_template
      {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.indicators.title", locale: locale)]
        end],
        data: []
      }
    end

  end
end
