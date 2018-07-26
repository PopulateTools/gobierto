# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class OrderedTermForm < BaseForm

      attr_accessor(
        :id,
        :site_id,
        :name_translations,
        :description_translations,
        :slug,
        :association
      )

      delegate :persisted?, to: :term

      validates :name_translations, :site, presence: true

      def term
        @term ||= terms_relation.find_by(id: id) || build_term
      end

      def save
        save_term if valid?
      end

      private

      def build_term
        terms_relation.new
      end

      def save_term
        @term = term.tap do |attributes|
          attributes.name_translations = name_translations
          attributes.description_translations = description_translations
          attributes.slug = slug
        end

        return @term if @term.save

        promote_errors(@term.errors)
        false
      end

      def terms_relation
        site.send(association)
      end

      def site
        Site.find_by(id: site_id)
      end
    end
  end
end
