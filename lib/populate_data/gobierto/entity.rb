# frozen_string_literal: true

module PopulateData
  module Gobierto
    class Entity < Client
      ENDPOINT_URI = "/collections/c-entidades-presupuestos-municipales/items"

      attr_reader(
        :municipality_id
      )

      def initialize(options = {})
        @municipality_id = options.fetch(:municipality_id)

        super(options)
      end

      private

      def request_body
        {
          filter_by_municipality_id: @municipality_id
        }.to_json
      end
    end
  end
end
