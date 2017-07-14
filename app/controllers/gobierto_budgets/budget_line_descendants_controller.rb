class GobiertoBudgets::BudgetLineDescendantsController < GobiertoBudgets::ApplicationController
  before_action :load_params

  def index
    conditions = { site: current_site, place: @place, year: @year, kind: @kind, area_name: @area_name }

    if @parent_code
      conditions.merge!({parent_code: @parent_code})
    else
      conditions.merge!({level: 1})
    end

    @budget_lines = []
    budget_lines = GobiertoBudgets::BudgetLine.where(conditions).all
    @budget_lines = budget_lines

    if !request.format.json? && @parent_code && @parent_code.length >= 1
      while budget_lines.any?
        children_budget_lines = budget_lines
        budget_lines = []
        children_budget_lines.each do |budget_line|
          budget_lines.concat GobiertoBudgets::BudgetLine.where(conditions.merge({parent_code: budget_line.code})).all
        end
        @budget_lines.concat budget_lines
      end
    end

    respond_to do |format|
      format.js
      format.json { render json: @budget_lines.to_json }
    end
  end

  private

  def load_params
    @place = @site.place
    render_404 and return if @place.nil?

    @year = params[:year]
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::FunctionalArea.area_name
    @parent_code = params[:parent_code]
  end

end
