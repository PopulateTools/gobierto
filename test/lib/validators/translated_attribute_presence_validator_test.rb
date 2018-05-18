# frozen_string_literal: true

require "test_helper"

class Validatable
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :translated_attribute_translations
  validates :translated_attribute_translations, translated_attribute_presence: true
end

class TranslatedAttributePresenceValidatorTest < ActiveSupport::TestCase

  def test_validate_valid_attribute
    validatable = Validatable.new(translated_attribute_translations: { "en" => "foo", "es" => "" })

    assert validatable.valid?
  end

  def test_validate_invalid_attribute
    validatable = Validatable.new

    refute validatable.valid?

    validatable = Validatable.new(translated_attribute_translations: {})

    refute validatable.valid?

    validatable = Validatable.new(translated_attribute_translations: { "en" => "" })

    refute validatable.valid?
    assert validatable.errors.messages[:translated_attribute_translations].present?
  end

end
