# frozen_string_literal: true

class GobiertoBudgets::IndicatorsController < GobiertoBudgets::ApplicationController
  before_action :load_year

  def index
  end

  private

  def load_year
    if params[:year].nil?
      years = GobiertoBudgets::SearchEngineConfiguration::Year.all.delete_if {|x| x == Date.current.year }
      redirect_to gobierto_budgets_indicators_path(years.first)
    else
      @year = params[:year].to_i
    end
  end
end
