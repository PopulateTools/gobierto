class GobiertoBudgets::BudgetsController < GobiertoBudgets::ApplicationController
  before_action :load_year, except: [:guide]

  def index
    @kind = GobiertoBudgets::BudgetLine::INCOME
    @area_name = GobiertoBudgets::EconomicArea.area_name
    @interesting_area = GobiertoBudgets::FunctionalArea.area_name

    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year

    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE).all
    @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 1, year: @year, kind: @kind, area_name: @area_name })
    @interesting_expenses = GobiertoBudgets::BudgetLine.all(where: { site: current_site, level: 2, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: @interesting_area })

    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)

    @budgets_data_updated_at = @site_stats.budgets_data_updated_at
    @budgets_execution_summary = @site_stats.budgets_execution_summary

    @any_custom_income_budget_lines  = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, area: GobiertoBudgets::CustomArea)
    @any_custom_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea)
  end

  def guide
    @year = GobiertoBudgets::SearchEngineConfiguration::Year.last
    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year
    if current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_guide_page"]
      @page = GobiertoCms::Page.find_by id: current_site.gobierto_budgets_settings.settings["budgets_guide_page"]
    end
  end

  private

  def load_year
    if params[:year].nil?
      default_year = if budgets_elaboration_active?
        GobiertoBudgets::SearchEngineConfiguration::Year.last_year_with_data - 1
      else
        GobiertoBudgets::SearchEngineConfiguration::Year.last_year_with_data
      end

      redirect_to gobierto_budgets_budgets_path(default_year)
    else
      @year = params[:year].to_i
    end
  end

end
