module PopulateData
  module Gobierto
    class Entity < Client

      ENDPOINT_URI = "/collections/c-entidades-presupuestos-municipales/items".freeze

      attr_reader(
        :municipality_id,
        :location_name
      )

      def initialize(options = {})
        @municipality_id = options.fetch(:municipality_id)
        @location_name = options.fetch(:location_name)

        super(options)
      end

      def fetch
        super.select do |entity|
          entity["municipality_id"] == @municipality_id &&
            entity["name"] == @location_name
        end
      end

      private

      def request_body
        {
          municipality_id: @municipality_id,
          location_name: @location_name
        }.to_json
      end

    end
  end
end
