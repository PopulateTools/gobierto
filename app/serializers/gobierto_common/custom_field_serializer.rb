# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldSerializer < ActiveModel::Serializer
    include ::GobiertoCommon::SerializableVocabularyTerms

    attributes :id, :uid, :name_translations, :field_type, :options, :vocabulary_terms

    def vocabulary_terms
      return unless object.has_vocabulary?

      if object.vocabulary.present?
      serialize_terms(object.vocabulary.terms.sorted)
      elsif object.vocabularies.present?
        object.vocabularies.map do |vocabulary|
          serialize_terms(vocabulary.terms.sorted)
        end
      end.flatten
    end
  end
end
