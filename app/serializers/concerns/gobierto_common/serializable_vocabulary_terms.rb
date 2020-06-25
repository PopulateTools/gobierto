# frozen_string_literal: true

module GobiertoCommon
  module SerializableVocabularyTerms
    extend ActiveSupport::Concern

    def vocabularies_serialization_options
      @vocabularies_serialization_options ||= instance_options.slice(:vocabularies_adapter, :with_translations).tap do |options|
        options[:adapter] = options.delete :vocabularies_adapter
      end
    end

    def json_api_vocabularies_adapter?
      vocabularies_serialization_options[:adapter] == :json_api
    end

    def serialize_terms(terms_relation)
      json = ActiveModelSerializers::SerializableResource.new(terms_relation, **vocabularies_serialization_options).as_json
      return json unless json_api_vocabularies_adapter?

      json.fetch(:data, [])
    end
  end
end
