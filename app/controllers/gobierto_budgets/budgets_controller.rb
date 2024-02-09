class GobiertoBudgets::BudgetsController < GobiertoBudgets::ApplicationController
  before_action :load_year, except: [:guide]
  before_action :overrided_root_redirect, only: [:index]

  caches_action(
    :index,
    cache_path: -> { cache_service.prefixed(cache_path) },
    unless: -> { user_signed_in? }
  )

  def index
    @kind = GobiertoBudgets::BudgetLine::INCOME
    @area_name = GobiertoBudgets::EconomicArea.area_name
    @interesting_area = GobiertoBudgets::FunctionalArea.area_name

    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(budget_query_params.merge(kind: GobiertoBudgets::BudgetLine::INCOME)).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(budget_query_params.merge(kind: GobiertoBudgets::BudgetLine::EXPENSE)).all
    load_place_budget_lines
    load_interesting_expenses

    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)

    load_site_stats
    @budgets_data_updated_at = @site_stats.budgets_data_updated_at
    @budgets_execution_summary = @site_stats.budgets_execution_summary

    @any_custom_income_budget_lines  = GobiertoBudgets::BudgetLine.any_data?(budget_query_params.merge(kind: GobiertoBudgets::BudgetLine::INCOME, area: GobiertoBudgets::CustomArea))
    @any_custom_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(budget_query_params.merge(kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea))
  end

  def guide
    @year = GobiertoBudgets::SearchEngineConfiguration::Year.last
    load_site_stats

    if current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_guide_page"]
      @page = GobiertoCms::Page.find_by id: current_site.gobierto_budgets_settings.settings["budgets_guide_page"]
    end
  end

  private

  def cache_path
    "#{super}/#{@year}"
  end

  def load_year
    default_year = if budgets_elaboration_active?
                     GobiertoBudgets::SearchEngineConfiguration::Year.last_year_with_data - 1
                   else
                     GobiertoBudgets::SearchEngineConfiguration::Year.last_year_with_data
                   end

    if params[:year].nil?
      redirect_to gobierto_budgets_budgets_path(default_year)
    else
      @year = params[:year].to_i
      if @year > default_year
        redirect_to gobierto_budgets_budgets_path(default_year)
      end
    end
  end

  def load_site_stats
    @site_stats = GobiertoBudgets::SiteStats.new(budget_query_params)
  end

  def budget_query_params
    { site: current_site, year: @year }
  end

  def load_place_budget_lines
    conditions = {
      site: current_site,
      level: 1,
      year: @year,
      kind: @kind,
      area_name: @area_name
    }

    @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: conditions, updated_forecast: false)
  end

  def load_interesting_expenses
    conditions = {
      site: current_site,
      level: 2,
      year: @year,
      kind: GobiertoBudgets::BudgetLine::EXPENSE,
      area_name: @interesting_area
    }

    @interesting_expenses = GobiertoBudgets::BudgetLine.all(where: conditions, updated_forecast: false)
  end

end
