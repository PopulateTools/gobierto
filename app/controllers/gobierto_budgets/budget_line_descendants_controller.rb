class GobiertoBudgets::BudgetLineDescendantsController < GobiertoBudgets::ApplicationController
  before_action :load_params

  def index
    conditions = { site: current_site, year: @year, kind: @kind, area_name: @area_name }

    if @parent_code
      conditions.merge!(parent_code: @parent_code)
    else
      conditions.merge!(level: 1)
    end

    @budget_lines = GobiertoBudgets::BudgetLine.all(where: conditions, updated_forecast: true)

    if !request.format.json? && @parent_code && @parent_code.length >= 1
      @budget_lines = expand_children(@budget_lines, conditions)
    end

    respond_to do |format|
      format.js
      format.json { render json: @budget_lines.to_json }
    end
  end

  private

  def expand_children(budget_lines, conditions)
    budget_lines.concat(budget_lines.map do |budget_line|
      if budget_line.level < 4
        expand_children(GobiertoBudgets::BudgetLine.all(where: conditions.merge(parent_code: budget_line.code), updated_forecast: true), conditions)
      end
    end.flatten.compact)
  end

  def load_params
    @year = params[:year]
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::FunctionalArea.area_name
    @parent_code = params[:parent_code]
  end

end
