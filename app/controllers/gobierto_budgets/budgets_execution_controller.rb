class GobiertoBudgets::BudgetsExecutionController < GobiertoBudgets::ApplicationController
  before_action :load_place, :load_year

  def index
    @top_possitive_difference_income, @top_negative_difference_income = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, type: 'economic')

    if @top_possitive_difference_income.empty?
      flash[:alert] = t('controllers.gobierto_budgets.budgets_execution.index.alert', year: @year)
      redirect_to gobierto_budgets_budgets_execution_path(@year -1) and return
    end

    @top_possitive_difference_expending_economic, @top_negative_difference_expending_economic = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: 'economic')
    @top_possitive_difference_expending_functional, @top_negative_difference_expending_functional = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: 'functional')
    @any_custom_income_budget_lines = GobiertoBudgets::CustomArea.any_items?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME)

    @budgets_data_updated_at   = current_site.budgets_data_updated_at('execution')
    @budgets_execution_summary = current_site.budgets_execution_summary
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
