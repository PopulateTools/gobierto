# frozen_string_literal: true

require "test_helper"

class TranslatedAttributePresenceValidatorTest < ActiveSupport::TestCase

  def site
    @site ||= sites(:madrid)
  end

  def collection
    @collection ||= person.events_collection
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def create_event(title_translations)
    ::GobiertoCalendars::Event.new(
      site: site,
      collection: collection,
      title_translations: title_translations
    )
  end

  def remove_test_validation
    ::GobiertoCalendars::Event.class_eval do
      _validators[:title_translations].find do |v|
        v.is_a? TranslatedAttributeLengthValidator
      end.attributes.delete(:title_translations)

      _validate_callbacks.each do |callback|
        if callback.raw_filter.respond_to? :attributes
          callback.raw_filter.attributes.delete :title_translations
        end
      end
    end
  end

  def setup
    super
    ::GobiertoCalendars::Event.class_eval do
      validates :title_translations, translated_attribute_length: { maximum: 10 }
    end
  end

  def teardown
    super
    remove_test_validation
  end

  def test_validate_valid_attribute
    validatable = create_event("en" => "0123")

    assert validatable.valid?
  end

  def test_validate_invalid_attribute
    validatable = create_event("en" => "01234567890", "es" => "0123")

    refute validatable.valid?

    error_messages = validatable.errors.messages[:title_translations]

    assert error_messages.include?("is too long (maximum is 10 characters) (EN)")
  end

end
