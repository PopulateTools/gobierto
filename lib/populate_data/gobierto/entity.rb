module PopulateData
  module Gobierto
    class Entity < Client

      ENDPOINT_URI = "/collections/c-entidades-presupuestos-municipales/items".freeze

      attr_reader(
        :municipality_id
      )

      def initialize(options = {})
        @municipality_id = options.fetch(:municipality_id)

        super(options)
      end

      def fetch
        super.select do |entity|
          entity["municipality_id"] == @municipality_id
        end
      end

    end
  end
end
