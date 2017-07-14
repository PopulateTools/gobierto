class GobiertoBudgets::BudgetsController < GobiertoBudgets::ApplicationController
  before_action :load_place
  before_action :load_year, except: [:guide]

  def index
    @kind = GobiertoBudgets::BudgetLine::INCOME
    @area_name = GobiertoBudgets::EconomicArea.area_name
    @interesting_area = GobiertoBudgets::FunctionalArea.area_name

    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year

    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::INCOME).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::EXPENSE).all
    @place_budget_lines = GobiertoBudgets::BudgetLine.where(site: current_site, place: @place, level: 1, year: @year, kind: @kind, area_name: @area_name).all
    @interesting_expenses = GobiertoBudgets::BudgetLine.where(site: current_site, place: @place, level: 2, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: @interesting_area).all

    @any_custom_income_budget_lines  = GobiertoBudgets::CustomArea.any_items?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME)
    @any_custom_expense_budget_lines = GobiertoBudgets::CustomArea.any_items?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE)

    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)
  end

  def guide
    @year = GobiertoBudgets::SearchEngineConfiguration::Year.last
    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year
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
