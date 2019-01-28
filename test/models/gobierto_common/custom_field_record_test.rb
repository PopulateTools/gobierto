# frozen_string_literal: true

require "test_helper"

class GobiertoCommon::CustomFieldRecordTest < ActiveSupport::TestCase
  def custom_field_single_option
    @custom_field_single_option ||= gobierto_common_custom_fields(:madrid_custom_field_country)
  end

  def custom_field_localized_string
    @custom_field_localized_string ||= gobierto_common_custom_fields(:madrid_custom_field_position)
  end

  def custom_field_paragraph
    @custom_field_paragraph ||= gobierto_common_custom_fields(:madrid_custom_field_bio)
  end

  def custom_field_multiple_options
    @custom_field_multiple_options ||= gobierto_common_custom_fields(:madrid_custom_field_languages)
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_value_assignment
    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_single_option
    subject.item = person
    subject.value = "test"
    assert_equal "test", subject.payload[custom_field_single_option.uid]
  end

  def test_raw_value
    [custom_field_localized_string,
     custom_field_paragraph,
     custom_field_single_option,
     custom_field_multiple_options,
     custom_field_multiple_options].each do |custom_field|
       subject = GobiertoCommon::CustomFieldRecord.new
       subject.custom_field = custom_field
       subject.value = "randomstring1"
       assert_equal "randomstring1", subject.raw_value
     end
  end

  def test_values
    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_single_option
    subject.value = "es"
    assert_equal "Spain", subject.value

    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_localized_string
    subject.value = { es: "test_es", en: "test_en" }
    assert_equal "test_en", subject.value

    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_paragraph
    subject.value = "randomstring1"
    assert_equal "randomstring1", subject.value

    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_multiple_options
    subject.value = %w(es pt)
    assert_equal %w(Spanish Portuguese), subject.value
  end

  def test_wrong_item_class
    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_localized_string
    subject.value = { es: "Inválido", en: "Invalid" }
    subject.item = person

    assert subject.valid?

    subject.item = site

    refute subject.valid?
    assert_not_nil subject.errors[:item]
  end

  def test_localized_string_fallback_value
    subject = GobiertoCommon::CustomFieldRecord.new
    subject.custom_field = custom_field_localized_string
    subject.value = { es: "test_es", en: "test_en" }

    I18n.locale = :ca
    assert_equal "test_en", subject.value
  end
end
