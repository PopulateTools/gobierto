module GobiertoPlans
  module CategoryTermDecoratorIndicatorsAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(plan, node)
      super_result = super

      super_result[:indicators] = {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.indicators.title", locale: locale)]
        end],
        data: []
      }

      indicators_fields = site.custom_fields.where(
        "options @> ?",
        { configuration: { plugin_type: "indicators" } }.to_json
      )
      records = ::GobiertoPlans::Node.node_custom_field_records(plan, node).where(custom_field: indicators_fields)
      indicators_payload = records.map(&:payload).compact.reduce({}, :merge)

      indicators_payload.each do |indicator_id, values|
        indicator = ::GobiertoCommon::Term.find(indicator_id)

        super_result[:indicators][:data].append(
          id: indicator_id.to_i,
          name_translations: indicator.name_translations,
          description_translations: indicator.description_translations,
          last_value: values.to_a.sort_by { |item| Date.strptime(item[0], "%Y-%m") }
                            .reverse.first.second,
          values: values
        )
      end

      super_result
    end

  end
end
