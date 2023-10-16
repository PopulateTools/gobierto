# frozen_string_literal: true

module GobiertoCommon
  class VocabularySerializer < ActiveModel::Serializer
    attributes(
      :id,
      :name_translations,
      :slug,
      :terms
    )

    def terms
      return if object.terms.blank?

      serialize_terms(object.terms.sorted)
    end

    def serialize_terms(terms_relation)
      ActiveModelSerializers::SerializableResource.new(terms_relation, each_serializer: ::GobiertoCommon::ApiTermSerializer).as_json
    end
  end
end
