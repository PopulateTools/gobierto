# frozen_string_literal: true

module PopulateDataHelpers
  def with_stubbed_budget_line_collection
    GobiertoAdmin::GobiertoBudgetConsultations::BudgetLineCollectionBuilder.stub_any_instance(:call, [populate_data_budget_line_summary]) do
      yield
    end
  end

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

  def with_stubbed_populate_data_plan
    populate_data_plan do
      yield
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

  def populate_data_plan
    "[{\"id\":760939060,\"uid\":\"0\",\"level\":0,\"attributes\":{\"title\":{\"en\":\"City\",\"es\":\"Ciudad\"},\"parent_id\":null,\"progress\":0,\"img\":\"http://gobierto.es/assets/v2/logo-gobierto.svg\"},\"children\":[]},{\"id\":806940941,\"uid\":\"1\",\"level\":0,\"attributes\":{\"title\":{\"en\":\"Economy\",\"es\":\"Economía\"},\"parent_id\":null,\"progress\":0,\"img\":\"http://gobierto.es/assets/v2/logo-gobierto.svg\"},\"children\":[]},{\"id\":309767805,\"uid\":\"2\",\"level\":0,\"attributes\":{\"title\":{\"en\":\"People and families\",\"es\":\"Personas y familias\"},\"parent_id\":null,\"progress\":null,\"img\":\"http://gobierto.es/assets/v2/logo-gobierto.svg\"},\"children\":[{\"id\":953101899,\"uid\":\"2.0\",\"level\":1,\"attributes\":{\"title\":{\"en\":\"Provide social assistance to individuals and families who need it for lack of resources\",\"es\":\"Proporcionar asistencia social a las personas y familias que la necesiten por falta de recursos\"},\"parent_id\":309767805,\"progress\":25.0},\"children\":[{\"id\":1059973494,\"uid\":\"2.0.0\",\"level\":2,\"attributes\":{\"title\":{\"en\":\"Necesidades básicas de las familias del Distrito Centro\",\"es\":\"Basic needs of District Center families\"},\"parent_id\":953101899,\"progress\":50.0},\"children\":[{\"id\":963320858,\"uid\":\"2.0.0.0\",\"level\":3,\"attributes\":{\"title\":{\"en\":\"Publish political agendas\",\"es\":\"Publicar agendas políticas\"},\"parent_id\":1059973494,\"progress\":50.0,\"starts_at\":\"2017-11-06\",\"ends_at\":\"2018-05-06\",\"status\":{\"en\":\"In progress\",\"es\":\"En progreso\"},\"options\":{\"objetivos\":\"Improve pedestrian and vehicle safety\",\"temporality\":\"annual\"}},\"children\":[]}]},{\"id\":713382146,\"uid\":\"2.0.1\",\"level\":2,\"attributes\":{\"title\":{\"en\":\"Scholarships for families in the Central District\",\"es\":\"Becas las familias del Distrito Centro\"},\"parent_id\":953101899,\"progress\":0.0},\"children\":[{\"id\":252926840,\"uid\":\"2.0.1.0\",\"level\":3,\"attributes\":{\"title\":{\"en\":\"Becas en guarderías\",\"es\":\"Scholarships in kindergartens\"},\"parent_id\":713382146,\"progress\":0.0,\"starts_at\":\"2017-10-06\",\"ends_at\":\"2018-07-06\",\"status\":{\"en\":\"Active\",\"es\":\"Activo\"},\"options\":null},\"children\":[]}]}]}]}]"
  end
end
