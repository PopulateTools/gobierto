# frozen_string_literal: true

module GobiertoCommon
  class PlainCustomFieldValueDecorator < BaseDecorator

    attr_accessor :plain_text_value

    attr_writer :allow_vocabulary_terms_creation

    def initialize(custom_field)
      @object = custom_field
    end

    def allow_vocabulary_terms_creation
      @allow_vocabulary_terms_creation ||= false
    end

    def value
      return unless plain_text_value

      if has_localized_value?
        localized_value
      elsif has_vocabulary?
        vocabulary_value
      elsif has_options?
        options_value
      else
        plain_text_value
      end
    end

    private

    def localized_value
      return unless has_localized_value?

      locale_key = site.configuration.default_locale || I18n.locale || I18n.default_locale
      { locale_key.to_s => plain_text_value }
    end

    def vocabulary_value
      return unless has_vocabulary?

      terms = vocabulary.terms
      if vocabulary_multiple_values?
        splitted_plain_text_value.map do |term|
          terms.with_name_translation(term).take&.id ||
            allow_vocabulary_terms_creation && terms.create(name: term)&.id
        end.compact.map(&:to_s)
      else
        (terms.with_name_translation(plain_text_value.strip).take ||
         allow_vocabulary_terms_creation && terms.create(name: plain_text_value.strip))&.id&.to_s
      end
    end

    def options_value
      return unless has_options?

      selections = multiple_options? ? splitted_plain_text_value : [plain_text_value.strip]

      values = selections.map do |selection|
        options.find do |_key, translations|
          translations.values.include? selection
        end
      end.compact.map(&:first)
      return values if multiple_options?

      values&.first
    end

    def vocabulary_multiple_values?
      return unless configuration

      configuration.vocabulary_type != "single_select"
    end

    def splitted_plain_text_value
      (CSV.parse_line(plain_text_value.tr("\n", ",")) || []).compact.map(&:strip)
    rescue CSV::MalformedCSVError
      plain_text_value.tr("\n", ",").split(",").compact.map(&:strip)
    end
  end
end
