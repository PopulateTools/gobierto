module GobiertoPlans
  module CategoryTermDecoratorBudgetsAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(node)
      super_result = super

      super_result[:budgets] = {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.budgets.title", locale: locale)]
        end],
        detail: {
          link: url_helpers.gobierto_budgets_root_url(host: site.domain),
          text: I18n.t("gobierto_plans.custom_fields_plugins.budgets.detail_text")
        }
      }

      budgets_fields = site.custom_fields.where(
        "options @> ?",
        { configuration: { plugin_type: "budgets" } }.to_json
      )
      records = node.custom_field_records.where(custom_field: budgets_fields)

      accumulated_planned_cost = 0
      accumulated_executed_cost = 0
      accumulated_progesses = []

      records.each do |record|
        accumulated_planned_cost += record.functions.planned_cost
        accumulated_executed_cost += record.functions.executed_cost
        accumulated_progesses.append(record.functions.progress)
      end

      accumulated_progess = 0
      accumulated_progess = (accumulated_progesses.sum / accumulated_progesses.size) if accumulated_progesses.any?

      super_result[:budgets][:budgeted_amount] = accumulated_planned_cost.round(2)
      super_result[:budgets][:executed_amount] = accumulated_executed_cost.round(2)
      super_result[:budgets][:executed_percentage] = "#{(accumulated_progess * 100).round} %"

      super_result
    end

  end
end
