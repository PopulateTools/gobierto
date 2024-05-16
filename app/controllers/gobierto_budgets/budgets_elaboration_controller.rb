class GobiertoBudgets::BudgetsElaborationController < GobiertoBudgets::ApplicationController
  before_action :check_setting_enabled, :load_year

  def index
    @site_stats = GobiertoBudgets::SiteStats.new(site: current_site, year: @year)
    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE).all
    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)
    @budgets_data_updated_at = @site_stats.budgets_data_updated_at

    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || (@kind == GobiertoBudgets::BudgetLine::EXPENSE ? GobiertoBudgets::FunctionalArea.area_name : GobiertoBudgets::EconomicArea.area_name)

    @interesting_expenses = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 2, year: @year, kind: @kind, area_name: @area_name })
    @interesting_expenses_previous_year = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 2, year: @year - 1, kind: @kind, area_name: @area_name })
    @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 1, year: @year, kind: @kind, area_name: @area_name })

    @any_custom_income_budget_lines  = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, area: GobiertoBudgets::CustomArea)
    @any_custom_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea)

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def check_setting_enabled
    render_404 unless budgets_elaboration_active?
  end

  def load_year
    @year = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last_year_with_data
  end

end
