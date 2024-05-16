# frozen_string_literal: true

class StubbedExternalRequestController < ApplicationController

  def populate_data_indicator
    render json: PopulateData::ApiMock.generic_indicator_data
  end

  def meta
    render json: PopulateData::ApiMock.meta
  end

  def user_signed_in?
    false
  end
  helper_method :user_signed_in?

  def bubbles_file
    year = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last.to_s
    previous_year = (GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last - 1).to_s

    render json: [
      {
        "budget_category": "expense",
        "id": "15",
        "pct_diff": {
          previous_year => 0,
          year => -1.35
        },
        "values": {
          previous_year => 604335087,
          year => 596148608
        },
        "values_per_inhabitant": {
          previous_year => 189.86,
          year => 184.95
        },
        "level_2_es": "Vivienda y urbanismo",
        "level_2_ca": "Habitatge i urbanisme"
      },
      {
        "budget_category": "income",
        "id": "29",
        "pct_diff": {
          previous_year => 0,
          year => 37.34
        },
        "values": {
          previous_year => 64388419,
          year => 88429832
        },
        "values_per_inhabitant": {
          previous_year => 20.23,
          year => 27.43
        },
        "level_2_es": "Otros impuestos indirectos",
        "level_2_ca": "Altres impostos indirectes"
      }
    ].to_json
  end

end
