# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldSerializer < ActiveModel::Serializer

    attributes :id, :uid, :name_translations, :field_type, :options, :vocabulary_terms

    def vocabulary_terms
      return unless object.has_vocabulary?

      ActiveModelSerializers::SerializableResource.new(object.vocabulary.terms).as_json
    end

  end
end
