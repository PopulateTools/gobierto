# frozen_string_literal: true

require "test_helper"
require "factories/total_budget_factory"

class TotalBudgetFactoryTest < ActiveSupport::TestCase
  INDEX = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast

  def client
    GobiertoBudgets::SearchEngine.client
  end

  def doc_id
    @doc_id ||= TotalBudgetFactory.doc_id({ organization_id: "factory-test", year: 2015 }, TotalBudgetFactory::TYPE)
  end

  def stored_document
    client.get(index: INDEX, id: doc_id)["_source"]
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end

  def teardown
    client.delete(index: INDEX, id: doc_id, refresh: true) if stored_document
    super
  end

  def test_teardown_restores_the_document_it_replaced
    existing_document = { "organization_id" => "factory-test", "year" => 2015, "kind" => "G", "type" => TotalBudgetFactory::TYPE, "amount" => 123 }
    client.index(index: INDEX, id: doc_id, body: existing_document, refresh: true)

    factory = TotalBudgetFactory.new(organization_id: "factory-test", year: 2015, total_budget: 999, indexes: [:forecast])
    assert_equal 999, stored_document["amount"]

    factory.teardown

    assert_equal existing_document, stored_document
  end

  def test_teardown_deletes_the_document_it_created
    factory = TotalBudgetFactory.new(organization_id: "factory-test", year: 2015, indexes: [:forecast])
    assert stored_document

    factory.teardown

    assert_nil stored_document
  end
end
