# frozen_string_literal: true

module PopulateData
  class ApiMock

    def self.stub_endpoint
      old_config = APP_CONFIG[:populate_data][:endpoint]
      APP_CONFIG[:populate_data][:endpoint] = "http://localhost:#{Capybara.current_session.server.port}/populate_data_mock/api/v1/data/data.json?sql="
      yield
    ensure
      Capybara.current_session.quit
      APP_CONFIG[:populate_data][:endpoint] = old_config
    end

    def self.generic_indicator_data
      data = [2017, 2018].map do |year|
        {
          value: 500_000 + year * 5,
          location_id: place.id,
          date: "#{year}-01-01",
          province_id: place.province_id,
          autonomous_region_id: place.province.autonomous_region_id,
          _id: "#{place.id}/#{year}-01-01"
        }
      end

      {
        "data": data,
        "metadata": {
          "indicator": {
            "name": "Indicator name",
            "description": "Indicator description",
            "source_name": "INE"
          }
        }
      }
    end

    def self.meta
      dt = {
        "data":
        { "id": "220",
          "type": "gobierto_data-datasets",
          "attributes": {
            "name": "Indicator name",
            "slug": "poblacion-edad-sexo",
            "table_name": "poblacion_edad_sexo",
            "data_updated_at": "2023-07-17T05:44:41.832+02:00",
            "columns": {
              "sex": { "type": "text" },
              "place_id": { "type": "integer" },
              "age": { "type": "integer" },
              "year": { "type": "integer" },
              "total": { "type": "text" }
            },
            "data_summary": { "number_of_rows": nil },
            "formats": { "csv": "/api/v1/data/datasets/poblacion-edad-sexo/download.csv" },
            "size": { "csv":100.0 },
            "default_limit": 50,
            "description": "<p>Indicator description</p>\n",
            "category": [{
              "id": 1314,
               "vocabulary_id": 23,
               "name_translations": { "es": "Demografía" },
               "description_translations": nil,
               "slug": "demografia",
               "position": 4,
               "level": 0,
               "term_id": nil,
               "created_at": "2020-03-27T15:02:22.277+01:00",
               "updated_at": "2020-03-27T15:02:22.277+01:00",
               "external_id": nil
              }],
              "frequency": [{
                "id": 1333,
                "vocabulary_id": 24,
                "name_translations": { "ca": "Anual", "en": "Annual", "es": "Anual" },
                "description_translations": nil,
                "slug": "anual",
                "position": 1,
                "level": 0,
                "term_id": nil,
                "created_at": "2020-03-27T15:02:24.068+01:00",
                "updated_at": "2020-03-27T15:02:24.068+01:00",
                "external_id": nil
              }],
              "dataset-source": "INE",
              "dataset-source-url": "",
              "dataset-license": [],
              "gobierto-default-geometry-data-column": ""
          },
          "relationships": {
            "queries": { "data": [] },
            "visualizations": { "data": [] },
            "attachments": { "data": [] }
          }
        },
        "links": {}
      }
    end

    def self.place
      INE::Places::Place.find_by_slug("madrid")
    end
    private_class_method :place

  end
end
