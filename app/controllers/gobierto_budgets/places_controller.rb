module GobiertoBudgets
  class PlacesController < GobiertoBudgets::ApplicationController
    layout :choose_layout
    before_action :get_params
    before_action :solve_income_area_mismatch, except: [:show]
    before_action :admin_user, only: [:intelligence]

    def show
      render_404 and return if @place.nil?
      if @year.nil?
        redirect_to gobierto_budgets_place_path(@place, GobiertoBudgets::SearchEngineConfiguration::Year.last) and return
      end

      @income_lines = GobiertoBudgets::BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, type: 'economic')
      @expense_lines = GobiertoBudgets::BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: @area_name)
      @no_data = @income_lines['hits'].empty?

      respond_to do |format|
        format.html
        format.js
      end
    end

    def execution
      render_404 and return if @place.nil?

      @top_possitive_difference_income, @top_negative_difference_income = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, type: 'economic')

      if @top_possitive_difference_income.empty?
        flash[:alert] = "No hay datos disponibles en #{@year} así que te mostramos el primer año con datos"
        redirect_to gobierto_budgets_place_execution_path(@place.slug, @year.to_i - 1) and return
      end

      @top_possitive_difference_expending_economic, @top_negative_difference_expending_economic = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: 'economic')
      @top_possitive_difference_expending_functional, @top_negative_difference_expending_functional = GobiertoBudgets::BudgetLine.top_differences(ine_code: @place.id, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, type: 'functional')
    end

    def debt_alive
    end

    def budget
      @level = (params[:parent_code].present? ? params[:parent_code].length + 1 : 1)

      options = { ine_code: @place.id, level: @level, year: @year, kind: @kind, type: @area_name }
      options[:parent_code] = params[:parent_code] if params[:parent_code].present?

      @budget_lines = GobiertoBudgets::BudgetLine.search(options)

      respond_to do |format|
        format.json do
          data_line = GobiertoBudgets::Data::Treemap.new place: @place, year: @year, kind: @kind, type: @area_name, parent_code: params[:parent_code]
          render json: data_line.generate_json
        end
        format.js
      end
    end

    # /places/compare/:slug_list/:year/:kind/:area
    def compare
      @places = get_places params[:slug_list]
      redirect_to gobierto_budgets_compare_path if @places.empty?

      @totals = GobiertoBudgets::BudgetTotal.for @places.map(&:id), @year
      @population = GobiertoBudgets::Population.for @places.map(&:id), @year
      if @population.empty?
        @population = GobiertoBudgets::Population.for @places.map(&:id), @year - 1
      end

      @compared_level = (params[:parent_code].present? ? params[:parent_code].length + 1 : 1)
      options = { ine_codes: @places.map(&:id), year: @year, kind: @kind, level: @compared_level, type: @area_name }

      if @compared_level > 1
        @budgets_and_ancestors = GobiertoBudgets::BudgetLine.compare_with_ancestors(options.merge(parent_code: params[:parent_code]))
        @budgets_compared = @budgets_and_ancestors.select {|bl| bl['parent_code'] == params[:parent_code]}
        @parent_compared = @budgets_and_ancestors.select {|bl| bl['code'] == params[:parent_code] }
      else
        @budgets_compared = @budgets_and_ancestors = GobiertoBudgets::BudgetLine.compare(options)
      end
    end

    def ranking
      @filters = params[:f]
      if @place && params[:page].nil?
        place_position = GobiertoBudgets::Ranking.place_position(year: @year, ine_code: @place.id, code: @code, kind: @kind, area_name: @area_name, variable: @variable, filters: @filters)

        page = GobiertoBudgets::Ranking.page_from_position(place_position)
        redirect_to url_for(params.merge(page: page)) and return
      end

      @per_page = GobiertoBudgets::Ranking.per_page
      @page = params[:page] ? params[:page].to_i : 1
      render_404 and return if @page <= 0

      @compared_level = params[:code] ? (params[:code].include?('-') ? params[:code].split('-').first.length : params[:code].length) : 0
      @ranking_items = GobiertoBudgets::Ranking.query({year: @year, variable: @variable, page: @page, code: @code, kind: @kind, area_name: @area_name, filters: @filters})

      respond_to do |format|
        format.html
        format.js
      end
    end

    def intelligence
    end

    private

    def get_params
      @place = INE::Places::Place.find_by_slug params[:slug] if params[:slug].present?
      @place = INE::Places::Place.find params[:ine_code] if params[:ine_code].present?
      @kind = ( %w{income i}.include?(params[:kind].downcase) ? GobiertoBudgets::BudgetLine::INCOME : GobiertoBudgets::BudgetLine::EXPENSE ) if action_name != 'show' && params[:kind]
      @kind ||= GobiertoBudgets::BudgetLine::EXPENSE if action_name == 'ranking'
      @area_name = params[:area] || 'functional'
      @year = params[:year].present? ? params[:year].to_i : nil
      @code = params[:code]
      if params[:variable].present?
        @variable = params[:variable]
        render_404 and return unless valid_variables.include?(@variable)
      end
    end

    def solve_income_area_mismatch
      area = (params[:area].present? ? params[:area].downcase : '')
      kind = (params[:kind].present? ? params[:kind].downcase : '')
      if %w{income i}.include?(kind) && area == 'functional'
        redirect_to url_for params.merge(area: 'economic', kind: 'I') and return
      end
    end

    def get_places(slug_list)
      slug_list.split(':').map {|slug| INE::Places::Place.find_by_slug slug}.compact
    end

    def valid_variables
      ['amount','amount_per_inhabitant','population']
    end

  end
end
