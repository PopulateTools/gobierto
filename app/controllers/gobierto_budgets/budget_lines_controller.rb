class GobiertoBudgets::BudgetLinesController < GobiertoBudgets::ApplicationController
  before_action :load_params
  before_action :check_elaboration, only: [:show]

  def index
    @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: { site: current_site, place: @place, level: @level, year: @year, kind: @kind, area_name: @area_name })
    @sample_budget_lines = GobiertoBudgets::TopBudgetLine.limit(20).where(site: current_site, year: @year, place: @site.place, kind: @kind).all.sample(3)

    @any_custom_income_budget_lines  = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, area: GobiertoBudgets::CustomArea)
    @any_custom_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea)
    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @budget_line = GobiertoBudgets::BudgetLine.first(where: { site: current_site, code: @code, place: @place, year: @year, kind: @kind, area_name: @area_name })
    if @budget_line.level > 1
      @parent_budget_line = GobiertoBudgets::BudgetLine.first(where: { site: current_site, code: @budget_line.parent_code, place: @place, year: @year, kind: @kind, area_name: @area_name })
    end
    @budget_line_stats = GobiertoBudgets::BudgetLineStats.new(site: @site, budget_line: @budget_line)
    @budget_line_descendants = GobiertoBudgets::BudgetLine.all(where: { site: current_site, place: @place, parent_code: @code, year: @year, kind: @kind, area_name: @area_name })
    if GobiertoBudgets::FunctionalArea.area_name == @area_name
      @budget_line_composition = GobiertoBudgets::BudgetLine.all(where: { site: current_site, place: @place, functional_code: @code, year: @year, kind: @kind, area_name: @area_name })
    elsif GobiertoBudgets::CustomArea.area_name == @area_name
      @budget_line_composition = GobiertoBudgets::BudgetLine.all(where: { site: current_site, place: @place, custom_code: @code, year: @year, kind: @kind, area_name: @area_name })
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
        data_line = GobiertoBudgets::Data::Treemap.new place: @place, year: @year, kind: @kind, type: @area_name, parent_code: params[:parent_code], level: params[:level]
        render json: data_line.generate_json
      end
      format.js
    end
  end

  private

  def load_params
    @place = @site.place
    render_404 and return if @place.nil?

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

end
