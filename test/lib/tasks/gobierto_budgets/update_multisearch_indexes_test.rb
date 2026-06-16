# frozen_string_literal: true

require "test_helper"

module GobiertoBudgets
  class UpdateMultisearchIndexesRakeTest < ActiveSupport::TestCase
    def setup
      super
      # Avoid hitting Elasticsearch for the population lookup performed in
      # BudgetLine#initialize.
      GobiertoBudgets::BudgetLine.stubs(:get_population).returns(666)

      # Loads the .rake file, which defines `create_budget_line` as a top-level
      # (private) method we can exercise here.
      Gobierto::Application.load_tasks unless respond_to?(:create_budget_line, true)
    end

    def site
      @site ||= sites(:madrid)
    end

    # Mimics an Elasticsearch v7 hit: the deprecated top-level "_type" is gone
    # and the area name now lives under "_source" => "type".
    def elasticsearch_hit(source_overrides = {})
      {
        "_index" => "index_forecast",
        "_id" => "28079/2015/1/G/#{EconomicArea.area_name}",
        "_source" => {
          "type" => EconomicArea.area_name,
          "kind" => BudgetLine::EXPENSE,
          "code" => "1",
          "year" => 2015,
          "amount" => 123.45
        }.merge(source_overrides)
      }
    end

    def test_create_budget_line_resolves_area_from_source_type
      budget_line = create_budget_line(site, "index_forecast", elasticsearch_hit)

      assert_equal EconomicArea, budget_line.area
      assert_equal EconomicArea.area_name, budget_line.area.area_name
      assert_equal BudgetLine::EXPENSE, budget_line.kind
      assert_equal "1", budget_line.code
      assert_equal 2015, budget_line.year
      assert_in_delta 123.45, budget_line.amount, 0.001
    end

    def test_create_budget_line_requires_type_in_source
      # Reading the now-removed top-level "_type" (the pre-fix behaviour) yields a
      # blank area_name, BudgetArea.klass_for returns nil and construction fails.
      hit_without_type = elasticsearch_hit.tap { |h| h["_source"].delete("type") }

      assert_raises(NoMethodError) do
        create_budget_line(site, "index_forecast", hit_without_type)
      end
    end
  end
end
