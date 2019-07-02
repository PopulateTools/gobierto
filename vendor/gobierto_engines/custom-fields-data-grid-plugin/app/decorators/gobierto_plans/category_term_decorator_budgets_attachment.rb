module GobiertoPlans
  module CategoryTermDecoratorBudgetsAttachment

    extend ActiveSupport::Concern

    private

    def node_plugins_data(plan, node)
      super_result = super

      super_result[:budgets] = {
        title_translations: Hash[I18n.available_locales.map do |locale|
          [locale, I18n.t("gobierto_plans.custom_fields_plugins.budgets.title", locale: locale)]
        end],
        detail: {
          link: url_helpers.gobierto_budgets_root_url(host: site.domain),
          text: I18n.t("gobierto_plans.custom_fields_plugins.budgets.detail_text")
        },
        budgeted_amount: nil,
        executed_amount: nil,
        executed_percentage: nil
      }

      budgets_fields = site.custom_fields.where(
        "options @> ?",
        { configuration: { plugin_type: "budgets" } }.to_json
      )
      records_functions = ::GobiertoPlans::Node.node_custom_field_records(plan, node)
                                               .where(custom_field: budgets_fields)
                                               .map(&:functions)

      return super_result if records_functions.empty?

      accumulated_planned_cost = 0
      accumulated_executed_cost = 0
      accumulated_progesses = []

      records_functions.each do |function|
        accumulated_planned_cost += function.planned_cost
        accumulated_executed_cost += function.executed_cost
        accumulated_progesses.append(function.progress)
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
