# frozen_string_literal: true

class TranslatedAttributeLengthValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    value.each do |locale_key, translation_value|
      current_length = translation_value&.length
      if options[:maximum] && current_length && current_length > options[:maximum]
        record.errors.add attribute, "#{I18n.t("errors.messages.too_long", count: options[:maximum])} (#{locale_key.upcase})"
      end
    end
  end

end
