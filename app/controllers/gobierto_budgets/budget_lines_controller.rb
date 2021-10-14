class GobiertoBudgets::BudgetLinesController < GobiertoBudgets::ApplicationController
  before_action :load_params

  caches_action(
    :show,
    :index,
    cache_path: -> { cache_path },
    unless: -> { user_signed_in? }
  )

  def index
    @place_budget_lines = updated_forecast(level: @level)
    @sample_budget_lines = GobiertoBudgets::TopBudgetLine.limit(20).where(site: current_site, year: @year, kind: @kind).all.sample(3)

    @any_custom_income_budget_lines  = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, area: GobiertoBudgets::CustomArea)
    @any_custom_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea)
    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @budget_line = GobiertoBudgets::BudgetLine.first(where: common_params.merge(code: @code))

    if @budget_line.level > 1
      @parent_budget_line = GobiertoBudgets::BudgetLine.first(where: common_params.merge(code: @budget_line.parent_code))
    end

    @budget_line_stats = GobiertoBudgets::BudgetLineStats.new(site: @site, budget_line: @budget_line)
    @budget_line_descendants = updated_forecast(parent_code: @code)
    @budget_line_composition = budget_line_composition

    respond_to do |format|
      format.html
      format.js
    end
  end

  def treemap
    respond_to do |format|
      format.json do
        data_line = GobiertoBudgets::Data::Treemap.new site: current_site, organization_id: current_site.organization_id, year: @year, kind: @kind, type: @area_name, parent_code: params[:parent_code], level: params[:level]
        render json: data_line.generate_json
      end
      format.js
    end
  end

  private

  def load_params
    @year = params[:year].to_i
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::FunctionalArea.area_name
    @level = params[:level].present? ? params[:level].to_i : 1
    @code = params[:id]
  end

  def common_params
    { site: current_site, year: @year, kind: @kind, area_name: @area_name }
  end

  # TODO: rename?
  def updated_forecast(params = {})
    GobiertoBudgets::BudgetLine.all(where: common_params.merge(params), updated_forecast: false)
  end

  def budget_line_composition
    case @area_name
    when GobiertoBudgets::FunctionalArea.area_name
      updated_forecast(functional_code: @code).group_by(&:first_level_parent_code)
    when GobiertoBudgets::CustomArea.area_name
      updated_forecast(custom_code: @code).group_by(&:first_level_parent_code)
    else
      []
    end
  end

  def cache_path
    "#{super}/#{ [@code, @year, @area_name, @kind, @level].compact.join("/") }"
  end

end
