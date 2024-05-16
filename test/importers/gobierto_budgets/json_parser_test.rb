# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::JsonParserTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def data
    @data = { test_data: "test", test_collection: [] }.to_json
  end

  def importer
    @importer ||= GobiertoBudgets::JsonParser.new(data, TestPresenter, site: site, year: 2017)
  end

  def test_organization
    assert_equal site.organization_id, importer.organization_id
  end

  def test_budgets_creation
    budgets = importer.budgets_for(GobiertoBudgets::EconomicArea, GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast)
    budgets_by_level = {}
    (1..4).each do |level|
      budgets_by_level[level] = budgets.select { |budget| budget[:index][:data][:level] == level }
    end
    assert_equal 13, budgets.count
    assert_equal 10, budgets_by_level[4].count
    assert_equal 1, budgets_by_level[1].count
  end

  def test_budgets_amounts
    budgets = importer.budgets_for(GobiertoBudgets::EconomicArea, GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast)
    budgets_by_level = {}
    (1..4).each do |level|
      budgets_by_level[level] = budgets.select { |budget| budget[:index][:data][:level] == level }
    end
    assert_equal budgets_by_level[1].sum { |budget| budget[:index][:data][:amount] }, budgets_by_level[4].sum { |budget| budget[:index][:data][:amount] }
  end

  class TestPresenter < BaseDecorator
    def self.detect_kind(kind_name)
      {
        "I" => GobiertoBudgets::BudgetLine::INCOME,
        "G" => GobiertoBudgets::BudgetLine::EXPENSE
      }[kind_name]
    end

    def self.collection_extractor
      ->(_json) { (1..10).map { |i| OpenStruct.new(index_code: i, amount: rand(1_000_000)) } }
    end

    def self.population_extractor
      ->(_json) { 1000 }
    end

    def self.kind_extractor
      ->(_json) { "G" }
    end

    def initialize(item)
      @object = item
    end

    def name
      "Budget Line"
    end

    def code(_area, level)
      ["1", "2", "3", "-0#{ object.index_code }"][0, level].join
    end

    def amount(_index)
      object.amount
    end
  end
end
