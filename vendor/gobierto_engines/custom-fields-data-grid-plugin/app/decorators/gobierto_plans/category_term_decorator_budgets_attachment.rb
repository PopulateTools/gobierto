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
        },
        budgeted_amount: nil,
        executed_amount: nil,
        executed_percentage: nil
      }

      field = site.custom_fields.find_by(
        "options @> ?",
        { configuration: { plugin_type: "budgets" } }.to_json
      )

      budget_lines = field&.records&.first&.payload&.dig("budget_lines") || []

      relative_total_amount = 0
      relative_executed_amount = 0

      budget_lines.map do |bl|
        next unless (weight = bl["weight"])

        details = GobiertoBudgets::BudgetLine.find_details(type: bl["area"], id: bl["id"])

        total_amount = details.forecast.updated_amount || details.forecast.original_amount

        next unless total_amount && weight

        relative_total_amount += (total_amount * weight) / 100
        relative_executed_amount += ((details.execution.amount || 0.0) * weight) / 100
      rescue GobiertoBudgets::BudgetLine::RecordNotFound
        next
      end

      if relative_total_amount.positive?
        super_result[:budgets][:budgeted_amount] = relative_total_amount.round(2)
        super_result[:budgets][:executed_amount] = relative_executed_amount.round(2)
        super_result[:budgets][:executed_percentage] = "#{((relative_executed_amount * 100) / relative_total_amount).round} %"
      end

      super_result
    end

  end
end
