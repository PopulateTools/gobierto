# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldSerializer < ActiveModel::Serializer
    include ::GobiertoCommon::SerializableVocabularyTerms

    attributes :id, :uid, :name_translations, :field_type, :options, :vocabulary_terms

    def vocabulary_terms
      return unless object.has_vocabulary?

      object.vocabularies.flat_map do |vocabulary|
        serialize_terms(vocabulary.terms.sorted)
      end
    end
  end
end
