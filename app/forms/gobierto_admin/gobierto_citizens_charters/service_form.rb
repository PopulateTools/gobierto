# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class ServiceForm < GobiertoCitizensCharters::BaseForm
      attr_accessor(
        :title_translations,
        :category_id,
        :slug
      )

      validates :category, presence: true
      validates :title_translations, translated_attribute_presence: true

      def available_categories
        categories_relation
      end

      def category
        categories_relation.find_by_id(category_id)
      end

      def attributes_assignments
        {
          title_translations: title_translations,
          category_id: category.id,
          slug: slug
        }
      end

      private

      def resources_relation
        site ? site.services : ::GobiertoCitizensCharters::Service.none
      end

      def categories_relation
        ::GobiertoCitizensCharters::Service.categories(site)
      end
    end
  end
end
