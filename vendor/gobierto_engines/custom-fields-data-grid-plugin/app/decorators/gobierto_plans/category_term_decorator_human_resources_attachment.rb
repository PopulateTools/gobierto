module GobiertoPlans
  module CategoryTermDecoratorHumanResourcesAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(node)
      super_result = super

      field = site.custom_fields.find_by(
        "options @> ?",
        { configuration: { plugin_type: "human_resources" } }.to_json
      )
      record = field.records.first

      super_result[:human_resources] = {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.human_resources.title", locale: locale)]
        end],
        budgeted_amount: record.functions.cost.round,
        executed_amount: ((record.functions.cost * record.functions.progress) / 100).round,
        executed_percentage: "#{record.functions.progress.round} %"
      }

      super_result
    end

  end
end
