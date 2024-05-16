# frozen_string_literal: true

class GobiertoBudgets::IndicatorsController < GobiertoBudgets::ApplicationController

  attr_reader :selected_year

  before_action :load_year
  helper_method :selected_year, :available_years

  def index
  end

  private

  def load_year
    if params[:year].nil?
      redirect_to gobierto_budgets_indicators_path(available_years.first)
    else
      @selected_year = params[:year].to_i
    end
  end

  def available_years
    @available_years ||= GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.all
  end

  def current_year
    Date.current.year
  end

end
