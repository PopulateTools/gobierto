# frozen_string_literal: true

module PopulateData
  class ApiMock

    def self.stub_endpoint
      APP_CONFIG["populate_data"]["endpoint"] = "http://localhost:#{Capybara.current_session.server.port}/populate_data_mock"
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
            "source name": "INE"
          }
        }
      }
    end

    def self.place
      INE::Places::Place.find_by_slug("madrid")
    end
    private_class_method :place

  end
end
