# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldSerializer < ActiveModel::Serializer

    attributes :id, :uid, :name_translations, :field_type, :options, :vocabulary_terms

    def vocabulary_terms
      return unless object.has_vocabulary?

      ActiveModelSerializers::SerializableResource.new(object.vocabulary.terms.sorted, **vocabularies_serialization_options).as_json
    end

    def vocabularies_serialization_options
      return {} unless instance_options[:vocabularies_adapter].present?

      { adapter: instance_options[:vocabularies_adapter] }
    end
  end
end
