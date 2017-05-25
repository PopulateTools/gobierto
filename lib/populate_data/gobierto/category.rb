# frozen_string_literal: true

module PopulateData
  module Gobierto
    class Category < Client
      ENDPOINT_URI = '/collections/c-categorias-presupuestos-municipales/items'

      attr_reader(
        :area,
        :kind,
        :level
      )

      def initialize(options = {})
        @area = options.fetch(:area)
        @kind = options.fetch(:kind)
        @level = options.fetch(:level)

        super(options)
      end

      def fetch
        super.select do |category|
          category['area'] == @area &&
            category['kind'] == @kind &&
            category['level'] == @level
        end
      end

      private

      def request_body
        {
          area: @area,
          kind: @kind,
          level: @level
        }.to_json
      end
    end
  end
end
