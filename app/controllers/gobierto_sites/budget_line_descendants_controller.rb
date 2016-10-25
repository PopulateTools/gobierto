class GobiertoSites::BudgetLineDescendantsController < GobiertoSites::ApplicationController
  before_action :load_params

  def index
    conditions = {place: @place, year: @year, kind: @kind, area_name: @area_name}
    if @parent_code
      conditions.merge!({parent_code: @parent_code})
    else
      conditions.merge!({level: 1})
    end

    @budget_lines = GobiertoBudgets::BudgetLine.where(conditions).all

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
    @area_name = params[:area_name] || GobiertoBudgets::BudgetLine::FUNCTIONAL
    @parent_code = params[:parent_code]
  end

end
