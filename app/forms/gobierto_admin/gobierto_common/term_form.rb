# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class TermForm < BaseForm

      attr_accessor(
        :id,
        :site_id,
        :vocabulary_id,
        :description_translations,
        :position,
        :slug,
        :term_id,
        :external_id
      )

      attr_writer(
        :name_translations
      )

      delegate :persisted?, to: :term

      validates :name_translations, :site, :vocabulary, presence: true
      validate :external_id_uniqueness_by_vocabulary

      def term
        @term ||= term_relation.find_by(id: id) || build_term
      end

      def build_term
        vocabulary.terms.new(position: next_position)
      end

      def name_translations
        @name_translations ||= term.name_translations
      end

      def save
        save_term if valid?
      end

      private

      def next_position
        (vocabulary.terms.maximum(:position) || -1) + 1
      end

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
          attributes.description_translations = description_translations if description_translations.present?
          attributes.slug = slug if slug.present?
          attributes.term_id = term_id
          attributes.position = position if position.present?
          attributes.external_id = external_id if external_id.present?
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

      def external_id_uniqueness_by_vocabulary
        return unless vocabulary.present? && external_id.present?

        errors.add :external_id, I18n.t("errors.messages.taken") if vocabulary.terms.where.not(id: term.id).where(external_id: external_id).exists?
      end
    end
  end
end
