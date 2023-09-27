# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class TermsForm < BaseForm

      TERM_FORM_EXTERNAL_ATTRIBUTES = %w(
      id
      name_translations
      description_translations
      slug
      position
      external_id
      )

      attr_accessor(
        :terms,
        :site_id,
        :vocabulary_id
      )

      validates :vocabulary, :site, presence: true

      def save
        return unless valid?

        ActiveRecord::Base.transaction do
          save_terms
        end
      end

      private

      def save_terms
        new_terms_data = terms.select do |attrs|
          find_existing_term(attrs).blank?
        end

        top_level_items(new_terms_data).each do |attrs|
          return false unless create_or_update_term(attrs, terms)
        end

        existing_terms_data = terms.select do |attrs|
          find_existing_term(attrs).present?
        end - new_terms_data

        existing_terms_data.each do |attrs|
          return false unless create_or_update_term(attrs, terms)
        end
      end

      def top_level_items(data)
        data.select do |attributes|
          parent_id = attributes["parent_id"]
          parent_id.blank? || data.none? { |attrs| attrs["external_id"] == parent_id }
        end
      end

      def vocabulary
        return unless site

        @vocabulary ||= site.vocabularies.find_by_id(vocabulary_id)
      end

      def create_or_update_term(attributes, data)
        term_form_attributes = attributes.slice(*TERM_FORM_EXTERNAL_ATTRIBUTES).merge(site_id:, vocabulary_id:)

        if (term = find_existing_term(attributes)).present?
          term_form_attributes["id"] = term.id
          %w(name_translations description_translations).each do |attr|
            term_form_attributes[attr] = term.name_translations.merge(term_form_attributes[attr]) if term_form_attributes[attr].present?
          end
        end

        if attributes.has_key?("parent_id")
          term_form_attributes["term_id"] = get_parent_id(attributes["parent_id"])
        end

        term_form = TermForm.new(term_form_attributes)

        unless term_form.save
          promote_errors(term_form.errors)
          return false
        end

        if (external_id = attributes["external_id"]).present?
          data.select { |attrs| attrs["parent_id"] == external_id }.each do |attrs|
            next if attrs["id"].blank? && vocabulary.terms.where(attrs.slice(*TERM_FORM_EXTERNAL_ATTRIBUTES)).exists?

            return false unless create_or_update_term(attrs, data)
          end
        else
          term_form.term
        end
      end

      def find_existing_term(attributes)
        if attributes["id"].present?
          vocabulary.terms.find_by(id: attributes["id"])
        elsif attributes["external_id"].present?
          vocabulary.terms.find_by(external_id: attributes["external_id"])
        end
      end

      def get_parent_id(id)
        return if id.blank?

        parent_term = vocabulary.terms.find_by(external_id: id) || vocabulary.terms.find_by(id:)
        return if parent_term.blank?

        parent_term.id
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end
    end
  end
end
