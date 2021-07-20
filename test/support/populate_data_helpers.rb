# frozen_string_literal: true

module PopulateDataHelpers
  def with_stubbed_budget_lines
    PopulateData::Gobierto::BudgetLine.stub_any_instance(:fetch, [populate_data_budget_line]) do
      yield
    end
  end

  def with_stubbed_entities
    PopulateData::Gobierto::Entity.stub_any_instance(:fetch, [populate_data_entity]) do
      yield
    end
  end

  def with_stubbed_categories
    PopulateData::Gobierto::Category.stub_any_instance(:fetch, [populate_data_category]) do
      yield
    end
  end

  def with_stubbed_populate_data
    with_stubbed_entities do
      with_stubbed_categories do
        with_stubbed_budget_lines do
          yield
        end
      end
    end
  end

  def populate_data_budget_line_summary
    {
      id: "9208.0/2016-01-01/p/e/f/151",
      entity_id: "9208.0",
      date: "2016",
      name: "Urbanismo",
      amount: 8000.0
    }
  end

  def populate_data_budget_line
    {
      "value" => 8000.0,
      "entity_id" => "9208.0",
      "date" => "2016",
      "municipality_id" => "28079", # INE::Places::Place.find_by_slug("madrid").id
      "province_id" => "34",
      "autonomous_region_id" => "7",
      "value_per_inhabitant" => 9.3,
      "type" => "planned",
      "kind" => "expense",
      "code" => "151",
      "parent_code" => "15",
      "functional_code" => nil,
      "custom_code" => nil,
      "area" => "functional",
      "level" => 3,
      "_id" => "9208.0/2016-01-01/p/e/f/151"
    }
  end

  def populate_data_entity
    {
      "name" => "Madrid",
      "municipality_id" => "28079", # INE::Places::Place.find_by_slug("madrid").id
      "province_id" => 34,
      "autonomous_region_id" => 7,
      "code" => "34232AA000",
      "_id" => "9208.0"
    }
  end

  def populate_data_category
    {
      "name" => "Urbanismo",
      "code" => "151",
      "parent_code" => "15",
      "level" => 3,
      "area" => "functional",
      "kind" => "expense",
      "_id" => "151/f/e"
    }
  end
end
