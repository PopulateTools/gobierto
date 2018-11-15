# frozen_string_literal: true

require "test_helper"

module GobiertoBudgets
  class BudgetLineTest < ActiveSupport::TestCase
    def setup
      super
      GobiertoBudgets::BudgetLine.stubs(:get_population).returns(666)
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
        amount: 123.45
      )
    end

    def budget_line_arguments_for_indexing
      {
        index: SearchEngineConfiguration::BudgetLine.index_forecast,
        type: EconomicArea.area_name,
        id: "28079/2015/1/G"
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
      client = mock

      client.expects(:index)
            .with(has_entries(budget_line_arguments_for_indexing))
            .returns("_shards" => { "failed" => 0 })

      client.stubs(:search).returns({"hits" => {
        "hits" => [
          {"_source" => { "kind" => "expense", "code" => "1", "name" => "Despeses de personal" }}
        ]
      }})

      SearchEngine.stubs(client: client)

      algolia_index = mock
      algolia_index.expects(:add_object).with(budget_line.algolia_as_json)
      BudgetLine.stubs(algolia_index: algolia_index)

      budget_line.save
    end

    def test_save_fail
      client = mock

      client.stubs(:search).returns({"hits" => {
        "hits" => [
          {"_source" => { "kind" => "expense", "code" => "1", "name" => "Despeses de personal" }}
        ]
      }})

      client.expects(:index)
            .with(has_entries(budget_line_arguments_for_indexing))
            .returns("_shards" => { "failed" => 1 })

      SearchEngine.stubs(client: client)

      algolia_index = mock

      algolia_index.expects(:add_object).with(budget_line.algolia_as_json).never

      BudgetLine.stubs(algolia_index: algolia_index)

      budget_line.save
    end

    def test_destroy
      algolia_index = mock

      algolia_index.expects(:delete_object).with(budget_line.algolia_id)

      BudgetLine.stubs(algolia_index: algolia_index)

      client = mock

      client.expects(:delete)
            .with(has_entries(budget_line_arguments_for_indexing))
            .returns("_shards" => { "failed" => 0 })

      SearchEngine.stubs(client: client)

      budget_line.destroy
    end

    def test_algolia_as_json
      expected_hash = {
        objectID: "index_forecast/economic/28079/2015/1/G",
        index: "index_forecast",
        type: "economic",
        site_id: site.id,
        organization_id: budget_line.organization_id,
        year: budget_line.year,
        code: budget_line.code,
        kind: budget_line.kind,
        resource_path: budget_line.resource_path,
        class_name: budget_line.class.name,
        "name_es"        => "Gastos de personal (custom, translated)",
        "description_es" => "Los gastos de personal son... (custom, translated)",
        "name_en"        => "Personal expenses (custom, translated)",
        "description_en" => "Personal expenses are... (custom, translated)",
        "name_ca"        => "Despeses de personal",
        "description_ca" => "Tot tipus de retribucions fixes i variables i indemnitzacions, en diners i en espècie, a satisfer per les entitats locals i els seus organismes autònoms al personal que hi presti els seus serveis. Cotitzacions obligatòries de les entitats locals i dels seus organismes autònoms als diferents règims de Seguretat Social del personal al seu servei. Prestacions socials, que comprenen tota classe de pensions i les remuneracions a concedir per raó de les càrregues familiars. Despeses de naturalesa social realitzades, en compliment d'acords i disposicions vigents, per les entitats locals i els seus organismes autònoms per al seu personal."
      }

      assert_equal expected_hash, budget_line.algolia_as_json
    end
  end
end
