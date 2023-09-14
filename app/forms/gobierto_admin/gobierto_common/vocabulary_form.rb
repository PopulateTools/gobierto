# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class VocabularyForm < BaseForm

      attr_accessor(
        :id,
        :site_id
      )

      attr_writer(
        :name_translations,
        :slug
      )

      delegate :persisted?, to: :vocabulary

      validates :name_translations, presence: true
      validates :site, presence: true

      def vocabulary
        @vocabulary ||= vocabulary_relation.find_by(id: id) || build_vocabulary
      end

      def build_vocabulary
        vocabulary_relation.new
      end

      def name_translations
        @name_translations ||= vocabulary.name_translations
      end

      def slug
        @slug ||= vocabulary.slug
      end

      def save
        save_vocabulary if valid?
      end

      private

      def save_vocabulary
        @vocabulary = vocabulary.tap do |attributes|
          attributes.site_id = site_id
          attributes.name_translations = name_translations
          attributes.slug = slug
        end

        return @vocabulary if @vocabulary.save

        promote_errors(@vocabulary.errors)
        false
      end

      def vocabulary_relation
        site.vocabularies
      end

      def site
        Site.find(site_id)
      end
    end
  end
end
