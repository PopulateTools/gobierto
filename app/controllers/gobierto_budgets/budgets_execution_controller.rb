class GobiertoBudgets::BudgetsExecutionController < GobiertoBudgets::ApplicationController
  before_action :load_place, :load_year

  def index
    @any_budgets_execution_data_for_year = GobiertoBudgets::BudgetLine.any_data?(site: current_site, index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)

    if !@any_budgets_execution_data_for_year
      flash[:alert] = t('controllers.gobierto_budgets.budgets_execution.index.alert', year: @year)
      redirect_to gobierto_budgets_budgets_execution_path(@year -1) and return
    end

    @top_possitive_difference_expending_economic, @top_negative_difference_expending_economic = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: 'economic')
    @top_possitive_difference_expending_functional, @top_negative_difference_expending_functional = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: 'functional')

    @any_economic_income_budget_lines    = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME,  area: GobiertoBudgets::EconomicArea,   index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_economic_expense_budget_lines   = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::EconomicArea,   index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_functional_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::FunctionalArea, index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_custom_income_budget_lines      = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME,  area: GobiertoBudgets::CustomArea,     index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)
    @any_custom_expense_budget_lines     = GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea,     index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, year: @year)

    @several_expenses_filters = [@any_economic_expense_budget_lines, @any_functional_expense_budget_lines, @any_custom_expense_budget_lines].any?{ |e| e == true }
    @several_income_filters   = [@any_economic_income_budget_lines, @any_custom_income_budget_lines].any?{ |e| e == true }

    @budgets_data_updated_at   = current_site.budgets_data_updated_at('execution')
    @budgets_execution_summary = GobiertoBudgets::SiteStats.new(site: current_site, year: @year).budgets_execution_summary
    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year
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
