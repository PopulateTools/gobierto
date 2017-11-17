class GobiertoBudgets::BudgetsExecutionController < GobiertoBudgets::ApplicationController
  before_action :load_place, :load_year

  def index
    unless @any_budgets_execution_data_for_year = GobiertoBudgets::BudgetLine.any_data?(site: current_site, index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
      flash[:alert] = t('controllers.gobierto_budgets.budgets_execution.index.alert', year: @year)
      redirect_to gobierto_budgets_budgets_execution_path(@year -1) and return
    end

    @any_economic_income_budget_lines    = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME,  area: GobiertoBudgets::EconomicArea,   index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_economic_expense_budget_lines   = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::EconomicArea,   index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_functional_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::FunctionalArea, index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_custom_income_budget_lines      = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME,  area: GobiertoBudgets::CustomArea,     index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_custom_expense_budget_lines     = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea,     index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)

    @several_expenses_filters = @any_economic_expense_budget_lines || @any_functional_expense_budget_lines || @any_custom_expense_budget_lines
    @several_income_filters   = @any_economic_income_budget_lines || @any_custom_income_budget_lines

    site_stats = GobiertoBudgets::SiteStats.new(site: @site, year: @year)
    @budgets_execution_summary = site_stats.budgets_execution_summary
    @budgets_data_updated_at   = site_stats.budgets_data_updated_at
  end

  private

  def load_place
    @place = @site.place
    render_404 and return if @place.nil?
  end

  def load_year
    if params[:year].nil?
      redirect_to gobierto_budgets_budgets_execution_path(GobiertoBudgets::SearchEngineConfiguration::Year.last)
    else
      @year = params[:year].to_i
    end
  end

end
