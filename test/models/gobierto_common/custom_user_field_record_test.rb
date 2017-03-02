require "test_helper"

class GobiertoCommon::CustomUserFieldRecordTest < ActiveSupport::TestCase
  def custom_user_field_single_option
    @custom_user_field_single_option ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_district)
  end

  def custom_user_field_string
    @custom_user_field_string ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_association)
  end

  def custom_user_field_paragraph
    @custom_user_field_paragraph ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_bio)
  end

  def custom_user_field_multiple_options
    @custom_user_field_multiple_options ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_interests)
  end

  def subject
    @subject ||= GobiertoCommon::CustomUserFieldRecord.new
  end

  def test_value_assignment
    subject.custom_user_field = custom_user_field_single_option
    subject.value = 'foo'
    assert_equal 'foo', subject.payload[custom_user_field_single_option.name]
  end

  def test_values
    subject.custom_user_field = custom_user_field_single_option
    subject.value = 'randomstring1'
    assert_equal 'Center', subject.value

    subject.custom_user_field = custom_user_field_string
    subject.value = 'randomstring1'
    assert_equal 'randomstring1', subject.value

    subject.custom_user_field = custom_user_field_paragraph
    subject.value = 'randomstring1'
    assert_equal 'randomstring1', subject.value

    subject.custom_user_field = custom_user_field_multiple_options
    subject.value = ['randomstring1']
    assert_equal ['Sports'], subject.value
  end
end
