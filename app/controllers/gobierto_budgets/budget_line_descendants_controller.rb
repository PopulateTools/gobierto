class GobiertoBudgets::BudgetLineDescendantsController < GobiertoBudgets::ApplicationController
  before_action :check_format
  before_action :load_params

  caches_action(
    :index,
    cache_path: -> { cache_service.prefixed(cache_path) },
    unless: -> { user_signed_in? }
  )

  def index
    conditions = { site: current_site, year: @year, kind: @kind, area_name: @area_name }

    if @parent_code
      conditions.merge!(parent_code: @parent_code)
    else
      conditions.merge!(level: 1)
    end

    @budget_lines = GobiertoBudgets::BudgetLine.all(where: conditions, updated_forecast: false)

    if !request.format.json? && @parent_code && @parent_code.length >= 1
      @budget_lines = expand_children(@budget_lines, conditions)
    end

    respond_to do |format|
      format.js
      format.json { render json: @budget_lines.to_json }
    end
  end

  private

  # Adds the descendants of the budget lines down to the fourth level, with one query per level
  def expand_children(budget_lines, conditions)
    parents = budget_lines

    loop do
      parent_codes = parents.select { |budget_line| budget_line.level < 4 }.map(&:code)
      break if parent_codes.empty?

      parents = GobiertoBudgets::BudgetLine.all(where: conditions.merge(parent_code: parent_codes), updated_forecast: false)
      budget_lines.concat(parents)
    end

    budget_lines
  end

  # The expand links are followed by crawlers, which request HTML
  def check_format
    raise ActionController::UnknownFormat unless request.format.js? || request.format.json?
  end

  def cache_path
    "#{super}/#{[@year, @area_name, @kind, @parent_code].compact.join("/")}"
  end

  def load_params
    @year = params[:year]
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::FunctionalArea.area_name
    @parent_code = params[:parent_code]
  end

end
