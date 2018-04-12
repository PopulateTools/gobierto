module GobiertoBudgets
  module BudgetLineAlgoliaHelpers
    extend ActiveSupport::Concern

    class_methods do

      def search_index_name
        "#{APP_CONFIG["site"]["name"]}_#{Rails.env}_#{self.name}"
      end

      def algolia_index
        @algolia_index ||= begin
          index = Algolia::Index.new(search_index_name)
          index.set_settings({ attributesForFaceting: [ 'site_id' ] })
          index
        end
      end

      def algolia_reindex_collection(budget_lines)
        objects = budget_lines.map { |bl| bl.algolia_as_json }
        algolia_index.add_objects(objects)
      end

      def algolia_destroy_records(site)
        algolia_index.delete_by_query('', filters: "site_id:#{site.id}")
      end

    end

    included do

      def algolia_id
        "#{index}/#{area.area_name}/#{organization_id}/#{year}/#{code}/#{kind}"
      end

      def algolia_as_json
        {
          objectID: algolia_id,
          index: index,
          type: area.area_name,
          site_id: site.id,
          organization_id: organization_id,
          year: year,
          code: code,
          kind: kind,
          resource_path: resource_path,
          class_name: self.class.name
        }.merge(translated_attributes)
      end

      def translated_attributes
        current_locale = I18n.locale
        translations = {}

        I18n.available_locales.each do |locale|
          I18n.locale = locale
          translations["name_#{locale}"] = get_name
          translations["description_#{locale}"] = get_description
        end

        I18n.locale = current_locale
        translations
      end

      def resource_path
        Rails.application.routes.url_helpers.gobierto_budgets_budget_line_path(
          area_name: area.area_name,
          kind: kind,
          year: year,
          id: code
        )
      end

    end

  end
end
