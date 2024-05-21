class GobiertoBudgets::BudgetsExecutionController < GobiertoBudgets::ApplicationController

  before_action :load_year
  helper_method :available_years

  def index
    unless @any_budgets_execution_data_for_year = any_execution_data?
      flash[:alert] = t('controllers.gobierto_budgets.budgets_execution.index.alert', year: @year)
      redirect_to gobierto_budgets_budgets_execution_path(@year - 1) and return
    end

    @any_economic_income_budget_lines    = any_execution_data?(kind: GobiertoBudgets::BudgetLine::INCOME,  area: GobiertoBudgets::EconomicArea)
    @any_economic_expense_budget_lines   = any_execution_data?(kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::EconomicArea)
    @any_functional_expense_budget_lines = any_execution_data?(kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::FunctionalArea)
    @any_custom_income_budget_lines      = any_execution_data?(kind: GobiertoBudgets::BudgetLine::INCOME,  area: GobiertoBudgets::CustomArea)
    @any_custom_expense_budget_lines     = any_execution_data?(kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea)

    @several_expenses_filters = @any_economic_expense_budget_lines || @any_functional_expense_budget_lines || @any_custom_expense_budget_lines
    @several_income_filters   = @any_economic_income_budget_lines || @any_custom_income_budget_lines

    site_stats = GobiertoBudgets::SiteStats.new(site: @site, year: @year)
    load_metric_boxes_info(site_stats)
    @budgets_data_updated_at = site_stats.budgets_data_updated_at
  end

  private

  def load_year
    if params[:year].nil?
      redirect_to gobierto_budgets_budgets_execution_path(GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last)
    else
      @year = params[:year].to_i
    end
  end

  def any_execution_data?(params={})
    conditions = default_search_conditions.clone
    conditions.merge!(area: params[:area]) if params[:area]
    conditions.merge!(kind: params[:kind]) if params[:kind]
    GobiertoBudgets::BudgetLine.any_data?(conditions)
  end

  def default_search_conditions
    @default_search_conditions ||= {
      site: current_site,
      index: search_index,
      year: @year
    }
  end

  def available_years
    @available_years ||= GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.with_data(index: search_index)
  end

  def search_index
    GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
  end

  def load_metric_boxes_info(site_stats)
    exec_summary = site_stats.budgets_execution_summary

    @income_metric_box = ::GobiertoBudgets::BudgetsExecution::MetricBoxCell.new(
      expense_type: :income,
      execution_summary: exec_summary
    )

    @execution_metric_box = ::GobiertoBudgets::BudgetsExecution::MetricBoxCell.new(
      expense_type: :expenses,
      execution_summary: exec_summary
    )
  end

end
