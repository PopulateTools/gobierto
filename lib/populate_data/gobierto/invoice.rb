# frozen_string_literal: true

module PopulateData
  module Gobierto
    class Invoice < Client
      ENDPOINT_URI = "/datasets/ds-facturas-municipio.json"

      attr_reader(
        :year,
        :location_id
      )

      def initialize(options = {})
        @location_id = options.fetch(:location_id)

        super(options)
      end

      private

      def request_body
        {
          filter_by_location_id: location_id,
          date_date_range: "20170101-20170531",
        }.to_json
      end
    end
  end
end
