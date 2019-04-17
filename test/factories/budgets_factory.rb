# frozen_string_literal: true

module BudgetsFactory

  extend ActiveSupport::Concern

  INDEXES = {
    forecast: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
    forecast_updated: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated,
    executed: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
  }

  class_methods do
    def default_population
      100
    end

    def default_place
      INE::Places::Place.find_by_slug("madrid")
    end

    def default_organization_id
      default_place.id
    end

    def default_code
      "1"
    end

    def default_kind
      GobiertoData::GobiertoBudgets::EXPENSE
    end

    def default_area
      GobiertoData::GobiertoBudgets::ECONOMIC_AREA_NAME
    end

    def default_year
      2019
    end

    def base_data
      {
        organization_id: default_organization_id,
        ine_code: default_place.id,
        province_id: default_place.province_id,
        autonomy_id: default_place.province.autonomous_region_id,
        year: default_year
      }
    end
  end

  attr_accessor :client, :created_documents

  def initialize(params = {})
    self.client = GobiertoBudgets::SearchEngine.client

    indexes = if params[:indexes]
      params[:indexes].map { |index_alias| INDEXES[index_alias] }
    else
      INDEXES.values
    end
    params.delete(:indexes)

    documents = indexes.map { |index| build_document(index, params) }
    result = client.bulk(body: documents)

    self.created_documents = result["items"].map do |doc|
      doc["index"].slice("_index", "_type", "_id")
    end

    sleep 1 # wait for search index to be ready
  end

  def teardown
    client.bulk(body: teardown_body)
  end

  private

  def teardown_body
    created_documents.map { |doc_summary| { delete: doc_summary } }
  end

end
