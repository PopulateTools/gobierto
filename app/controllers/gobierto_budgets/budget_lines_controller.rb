module GobiertoBudgets
  class BudgetLinesController < GobiertoBudgets::ApplicationController
    layout :choose_layout
    before_action :load_params

    def show
    end

    def feedback
      @question_id = params[:question_id].to_i
      render_404 and return unless [1,2].include?(@question_id)

      render 'show'
    end

    private

    def load_params
      @place = INE::Places::Place.find_by_slug params[:slug]
      @year = params[:year]
      @code = params[:code]
      @kind = ( %w{income i}.include?(params[:kind].downcase) ? GobiertoBudgets::BudgetLine::INCOME : GobiertoBudgets::BudgetLine::EXPENSE )
      @area_name = params[:area] || 'economic'

      options = { ine_code: @place.id, year: @year, kind: @kind, type: @area_name }

      @budget_line = BudgetLine.new year: @year, kind: @kind, place_id: @place.id, area_name: @area_name, code: @code

      @parent_line = BudgetLine.find(options.merge(code: @code))
      render_404 and return if @parent_line.nil?
      @budget_lines = BudgetLine.search(options.merge(parent_code: @code))
    end

  end
end
