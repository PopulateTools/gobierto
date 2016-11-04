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
