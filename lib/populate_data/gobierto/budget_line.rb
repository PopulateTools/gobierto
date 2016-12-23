module PopulateData
  module Gobierto
    class BudgetLine < Client

      ENDPOINT_URI = "/datasets/ds-presupuestos-municipales-partida.json".freeze

      attr_reader(
        :level,
        :type,
        :kind,
        :area,
        :date,
        :entity_id
      )

      def initialize(options = {})
        @level = options.fetch(:level)
        @type = options.fetch(:type)
        @kind = options.fetch(:kind)
        @area = options.fetch(:area)
        @date = options.fetch(:date).to_s
        @entity_id = options.fetch(:entity_id)

        super(options)
      end

      private

      def request_body
        {
          filter_by_level: @level,
          filter_by_type: @type,
          filter_by_kind: @kind,
          filter_by_area: @area,
          filter_by_date: @date,
          filter_by_entity_id: @entity_id
        }.to_json
      end

    end
  end
end
