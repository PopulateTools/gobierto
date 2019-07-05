module GobiertoPlans
  module CategoryTermDecoratorIndicatorsAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(plan, node)
      super_result = super(plan, node)

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

      records.map(&:payload).flatten.compact.each do |payload|
        next unless payload["indicator"]

        indicator = ::GobiertoCommon::Term.find(payload["indicator"])

        next unless indicator

        existing_indicator = super_result[:indicators][:data].find { |e| e[:id] == indicator.id }

        if existing_indicator
          if payload["value_reached"] && (indicator_date(payload["date"]) > indicator_date(existing_indicator[:date]))
            existing_indicator[:last_value] = payload["value_reached"]
            existing_indicator[:date] = payload["date"]
          end
        elsif payload["value_reached"] && payload["date"]
          super_result[:indicators][:data].append(
            id: indicator.id,
            name_translations: indicator.name_translations,
            description_translations: indicator.description_translations,
            last_value: payload["value_reached"],
            date: payload["date"]
          )
        end
      end

      super_result
    end

    def indicator_date(date_string)
      Date.strptime(date_string, "%Y-%m")
    rescue ArgumentError
      Date.strptime(date_string, "%Y")
    rescue ArgumentError
      nil
    end

  end
end
