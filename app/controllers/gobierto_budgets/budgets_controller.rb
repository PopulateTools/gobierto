class GobiertoBudgets::BudgetsController < GobiertoBudgets::ApplicationController
  before_action :load_place, :load_year

  def index
    @kind = GobiertoBudgets::BudgetLine::BUDGET_KINDS[:income]
    @area_name = GobiertoBudgets::BudgetLine::BUDGET_AREAS[:economic].area_name
    @interesting_area = GobiertoBudgets::BudgetLine::BUDGET_AREAS[:functional].area_name

    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year

    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::BUDGET_KINDS[:income]).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::BUDGET_KINDS[:expense]).all
    @place_budget_lines = GobiertoBudgets::BudgetLine.where(place: @place, level: 1, year: @year, kind: @kind, area_name: @area_name).all
    @interesting_expenses = GobiertoBudgets::BudgetLine.where(place: @place, level: 2, year: @year, kind: GobiertoBudgets::BudgetLine::BUDGET_KINDS[:expense], area_name: @interesting_area).all

    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)
  end

  private

  def load_place
    @place = @site.place
    render_404 and return if @place.nil?
  end

  def load_year
    if params[:year].nil?
      redirect_to gobierto_budgets_budgets_path(GobiertoBudgets::SearchEngineConfiguration::Year.last)
    else
      @year = params[:year].to_i
    end
  end

end
