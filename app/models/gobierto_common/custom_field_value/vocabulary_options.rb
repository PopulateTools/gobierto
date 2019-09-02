# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class VocabularyOptions < Base
    def value
      vocabulary.terms.where(id: raw_value)
    end

    def value_string
      value.map(&:name)
    end

    def filter_value
      raw_value.to_s
    end

    def value=(value)
      value = value.id if value.is_a?(GobiertoCommon::Term)

      if custom_field.configuration.vocabulary_type == "tags"
        if value&.any?
          existing_ids = vocabulary.terms.where(id: value).pluck(:id).map(&:to_s)
          new_tags = value - existing_ids
          start_position = vocabulary.terms.maximum(:position).to_i + 1

          new_terms_ids = new_tags.map.with_index do |new_term, i|
            vocabulary.terms.create(name: new_term, position: start_position + i).id
          end.compact
          value = existing_ids + new_terms_ids
        else
          value = []
        end
      end

      super
    end

    def vocabulary
      return unless custom_field.options.present?

      GobiertoCommon::Vocabulary.find_by(id: custom_field.options["vocabulary_id"])
    end
  end
end
