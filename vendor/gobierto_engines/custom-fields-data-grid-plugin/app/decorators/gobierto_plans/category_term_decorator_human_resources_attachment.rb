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
      record_functions = field&.records&.first&.functions(version: node.published_version)

      return super_result if record_functions.nil?

      super_result[:human_resources] = {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.human_resources.title", locale: locale)]
        end],
        budgeted_amount: record_functions.cost.round,
        executed_amount: ((record_functions.cost * record_functions.progress) / 100).round,
        executed_percentage: "#{record_functions.progress.round} %"
      }

      super_result
    end

  end
end
