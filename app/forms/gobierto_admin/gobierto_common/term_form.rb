# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class TermForm < BaseForm

      attr_accessor(
        :id,
        :site_id,
        :vocabulary_id,
        :name_translations,
        :description_translations,
        :slug,
        :term_id
      )

      delegate :persisted?, to: :term

      validates :name_translations, :site, :vocabulary, presence: true

      def term
        @term ||= term_relation.find_by(id: id) || build_term
      end

      def build_term
        vocabulary.terms.new
      end

      def save
        save_term if valid?
      end

      private

      def vocabulary
        @vocabulary ||= begin
                          return unless site
                          if vocabulary_id
                            site.vocabularies.find_by_id(vocabulary_id)
                          else
                            term_relation.find_by_id(id)&.vocabulary
                          end
                        end
      end

      def save_term
        @term = term.tap do |attributes|
          attributes.vocabulary_id = vocabulary.id
          attributes.name_translations = name_translations
          attributes.description_translations = description_translations
          attributes.slug = slug
          attributes.term_id = term_id
        end

        return @term if @term.save

        promote_errors(@term.errors)
        false
      end

      def term_relation
        site ? site.terms : ::GobiertoCommon::Term.none
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end
    end
  end
end
