# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class VocabularyOptions < Base
    def value
      vocabulary.terms.where(id: raw_value)
    end

    def value=(value)
      value = value.id if value.is_a?(GobiertoCommon::Term)

      super
    end

    def vocabulary
      return unless custom_field.options.present?

      GobiertoCommon::Vocabulary.find_by(id: custom_field.options["vocabulary_id"])
    end
  end
end
