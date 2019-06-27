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
      record_functions = field&.records&.first&.functions

      return super_result if record_functions.nil?

      # TODO: the version argument is not yet supported
      progress = record_functions.progress(version: node.published_version)
      cost = record_functions.cost(version: node.published_version)

      super_result[:human_resources] = {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.human_resources.title", locale: locale)]
        end],
        budgeted_amount: cost.round,
        executed_amount: ((cost * progress) / 100).round,
        executed_percentage: "#{progress.round} %"
      }

      super_result
    end

  end
end
