# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  class BudgetLineTest < ActiveSupport::TestCase
    def setup
      super
      GobiertoBudgets::BudgetLine.stubs(:get_population).returns(666)

      @client = mock
      @client.stubs(:search).returns({"hits" => {
        "hits" => [
          {"_source" => { "kind" => "expense", "code" => "1", "name" => "Despeses de personal" }}
        ]
      }})
    end

    def site
      @site ||= sites(:madrid)
    end

    def budget_line
      @budget_line ||= BudgetLine.new(
        site: site,
        index: "index_forecast",
        area_name: EconomicArea.area_name,
        kind: BudgetLine::EXPENSE,
        code: "1",
        year: 2015,
        amount: 123.45,
        type: EconomicArea.area_name,
      )
    end

    def budget_line_arguments_for_indexing
      {
        index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        id: "28079/2015/1/G/#{EconomicArea.area_name}"
      }
    end

    def test_get_level
      assert_equal 1, BudgetLine.get_level("0")
      assert_equal 1, BudgetLine.get_level("1")
      assert_equal 3, BudgetLine.get_level("123")
      assert_equal 4, BudgetLine.get_level("123-00")
    end

    def test_get_parent_code
      assert_nil BudgetLine.get_parent_code("0")
      assert_nil BudgetLine.get_parent_code("1")
      assert_equal "12", BudgetLine.get_parent_code("123")
      assert_equal "123", BudgetLine.get_parent_code("123-00")
    end

    def test_save
      @client.expects(:index)
             .with(has_entries(budget_line_arguments_for_indexing))
             .returns("_shards" => { "failed" => 0 })

      SearchEngine.stubs(client: @client)

      assert_difference "site.pg_search_documents.count", 1 do
        budget_line.save
      end

      assert site.multisearch("Gastos de personal").exists?
    end

    def test_save_fail
      @client.expects(:index)
             .with(has_entries(budget_line_arguments_for_indexing))
             .returns("_shards" => { "failed" => 1 })

      SearchEngine.stubs(client: @client)

      assert_no_difference "site.pg_search_documents.count" do
        budget_line.save
      end

      refute site.multisearch("Gastos de personal").exists?
    end

    def test_destroy
      @client.expects(:delete)
             .with(has_entries(budget_line_arguments_for_indexing))
             .returns("_shards" => { "failed" => 0 })

      SearchEngine.stubs(client: @client)

      GobiertoBudgets::BudgetLine.pg_search_reindex(budget_line)

      assert site.multisearch("Gastos de personal").exists?
      assert_difference "site.pg_search_documents.count", -1 do
        budget_line.destroy
      end
      refute site.multisearch("Gastos de personal").exists?
    end

    def test_any_data_in_any_area
      year = 2001
      factory = BudgetLineFactory.new(year: year, area: FunctionalArea.area_name, indexes: [:forecast])

      assert BudgetLine.any_data?(site: site, year: year)
    ensure
      factory&.teardown
    end

    def test_codes_with_children
      year = 2001
      factories = [
        BudgetLineFactory.new(code: "1", year: year, indexes: [:forecast]),
        BudgetLineFactory.new(code: "2", year: year, indexes: [:forecast]),
        BudgetLineFactory.new(code: "11", parent_code: "1", year: year, indexes: [:forecast]),
        BudgetLineFactory.new(code: "111", parent_code: "11", year: year, indexes: [:forecast]),
        BudgetLineFactory.new(code: "21", parent_code: "2", year: year, kind: BudgetLine::INCOME, indexes: [:forecast])
      ]

      codes_with_children = BudgetLine.codes_with_children(
        %w(1 2 11 111),
        organization_id: BudgetLineFactory.default_organization_id,
        year: year,
        kind: BudgetLine::EXPENSE,
        area: EconomicArea.area_name
      )

      assert_equal Set["1", "11"], codes_with_children
    ensure
      factories&.each(&:teardown)
    end

    def test_codes_with_children_without_codes
      assert_empty BudgetLine.codes_with_children(
        [],
        organization_id: BudgetLineFactory.default_organization_id,
        year: 2001,
        kind: BudgetLine::EXPENSE,
        area: EconomicArea.area_name
      )
    end
  end
end
