# frozen_string_literal: true

class GobiertoBudgets::BudgetLineDescendantsController < GobiertoBudgets::ApplicationController
  before_action :load_params

  def index
    conditions = { place: @place, year: @year, kind: @kind, area_name: @area_name }
    if @parent_code
      conditions[:parent_code] = @parent_code
    else
      conditions[:level] = 1
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
    render_404 && return if @place.nil?

    @year = params[:year]
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::BudgetLine::FUNCTIONAL
    @parent_code = params[:parent_code]
  end
end
