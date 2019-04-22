class GobiertoBudgets::BudgetLinesController < GobiertoBudgets::ApplicationController
  before_action :load_params
  before_action :check_elaboration, only: [:show]

  def index
    load_place_budget_lines
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
    @budget_line = GobiertoBudgets::BudgetLine.first(where: { site: current_site, code: @code, year: @year, kind: @kind, area_name: @area_name })
    if @budget_line.level > 1
      @parent_budget_line = GobiertoBudgets::BudgetLine.first(where: { site: current_site, code: @budget_line.parent_code, year: @year, kind: @kind, area_name: @area_name })
    end
    @budget_line_stats = GobiertoBudgets::BudgetLineStats.new(site: @site, budget_line: @budget_line)
    @budget_line_descendants = GobiertoBudgets::BudgetLine.all(where: { site: current_site, parent_code: @code, year: @year, kind: @kind, area_name: @area_name })
    if GobiertoBudgets::FunctionalArea.area_name == @area_name
      @budget_line_composition = GobiertoBudgets::BudgetLine.all(where: { site: current_site, functional_code: @code, year: @year, kind: @kind, area_name: @area_name })
    elsif GobiertoBudgets::CustomArea.area_name == @area_name
      @budget_line_composition = GobiertoBudgets::BudgetLine.all(where: { site: current_site, custom_code: @code, year: @year, kind: @kind, area_name: @area_name })
    else
      @budget_line_composition = []
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def treemap
    respond_to do |format|
      format.json do
        data_line = GobiertoBudgets::Data::Treemap.new organization_id: current_site.organization_id, year: @year, kind: @kind, type: @area_name, parent_code: params[:parent_code], level: params[:level]
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

  def check_elaboration
    if @year > Date.today.year && !budgets_elaboration_active?
      raise GobiertoBudgets::BudgetLine::RecordNotFound
    end
  end

  def load_place_budget_lines
    base_params = { site: current_site, level: @level, year: @year, kind: @kind, area_name: @area_name }

    @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: base_params.merge(index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated))

    if @place_budget_lines.empty?
      @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: base_params)
    end
  end

end
