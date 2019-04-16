# frozen_string_literal: true

class BudgetLineFactory

  attr_accessor :client, :created_documents

  INDEXES = {
    forecast: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
    forecast_updated: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated,
    executed: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
  }

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

  def self.default_code
    "1"
  end

  def self.default_kind
    GobiertoData::GobiertoBudgets::EXPENSE
  end

  def self.default_area
    GobiertoData::GobiertoBudgets::ECONOMIC_AREA_NAME
  end

  def self.default_year
    2019
  end

  private

  def teardown_body
    created_documents.map { |doc_summary| { delete: doc_summary } }
  end

  def default_attrs
    {
      organization_id: default_organization_id,
      ine_code: default_place.id,
      province_id: default_place.province_id,
      autonomy_id: default_place.province.autonomous_region_id,
      code: self.class.default_code,
      level: self.class.default_code.length,
      year: self.class.default_year,
      kind: self.class.default_kind
    }
  end

  def default_amount
    123_456.789
  end

  def default_place
    INE::Places::Place.find_by_slug("madrid")
  end

  def default_organization_id
    default_place.id
  end

  def default_population
    100
  end

  def default_doc_id
    [
      default_organization_id,
      self.class.default_year,
      self.class.default_code,
      self.class.default_kind
    ].join("/")
  end

  def amount_per_inhabitant(amount, population)
    (amount / population).round(2)
  end

  def build_document(index, params = {})
    amount = params[:amount] || self.class.default_amount
    population = params[:population] || default_population
    organization_id = params[:organization_id] || default_organization_id

    {
      index: {
        _index: index,
        _id: default_doc_id,
        _type: self.class.default_area,
        data: default_attrs.merge(
          amount: amount,
          population: population,
          amount_per_inhabitant: amount_per_inhabitant(amount, population)
        )
      }
    }
  end

end
