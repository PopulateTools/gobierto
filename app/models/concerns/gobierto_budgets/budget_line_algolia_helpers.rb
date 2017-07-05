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

    end

    included do

      def algolia_id
        "#{index}/#{area.area_name}/#{ine_code}/#{year}/#{code}/#{kind}"
      end

      def algolia_as_json
        {
          objectID: algolia_id,
          index: index,
          type: area.area_name,
          site_id: site.id,
          ine_code: ine_code,
          year: year,
          code: code,
          kind: kind
        }.merge(translated_attributes_hash)
      end

      def translated_attributes_hash
        current_locale = I18n.locale
        attributes_translations = {}

        I18n.available_locales.each do |locale|
          I18n.locale = locale
          attributes_translations["name_#{locale}"] = get_name
          attributes_translations["description_#{locale}"] = get_description
        end

        I18n.locale = current_locale
        attributes_translations
      end

    end

  end
end
