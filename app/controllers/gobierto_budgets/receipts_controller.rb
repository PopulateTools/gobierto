class GobiertoBudgets::ReceiptsController < GobiertoBudgets::ApplicationController

  before_action :check_setting_enabled

  def show
    year = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last
    @area = GobiertoBudgets::FunctionalArea.area_name
    @parents = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 1, year: year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: @area })
    @interesting_expenses = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 2, year: year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: @area })
  end

  private

  def check_setting_enabled
    render_404 unless budgets_receipt_active?
  end

end
