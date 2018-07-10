require "populate_data"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class BudgetLineCollectionBuilder
      def initialize(site, options = {})
        @site = site
        @municipality_id = site.organization_id
        @year = options.fetch(:year) { Date.current.year }
      end

      def call
        [].tap do |budget_line_summary|
          Array(entities).each do |entity|
            Array(budget_lines_for(entity["_id"])).each do |budget_line|
              matching_category = Array(categories).detect do |category|
                category["code"] == budget_line["code"]
              end

              next unless matching_category

              budget_line_summary << {
                id: budget_line["_id"],
                entity_id: entity["_id"],
                date: budget_line["date"],
                name: matching_category["name"],
                amount: budget_line["value"]
              }
            end
          end
        end
      end

      private

      def budget_lines_for(entity_id)
        PopulateData::Gobierto::BudgetLine.new(
          level: 3,
          type: "planned",
          kind: "expense",
          area: "functional",
          date: @year,
          entity_id: entity_id,
          origin: @site.domain,
          api_token: @site.configuration.populate_data_api_token
        ).fetch
      end

      def entities
        @entities ||= PopulateData::Gobierto::Entity.new(
          municipality_id: @municipality_id,
          origin: @site.domain,
          api_token: @site.configuration.populate_data_api_token
        ).fetch
      end

      def categories
        @categories ||= PopulateData::Gobierto::Category.new(
          level: 3,
          kind: "expense",
          area: "functional",
          origin: @site.domain,
          api_token: @site.configuration.populate_data_api_token
        ).fetch
      end
    end
  end
end
