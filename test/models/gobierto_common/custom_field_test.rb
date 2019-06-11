# frozen_string_literal: true

require "test_helper"

class GobiertoCommon::CustomFieldTest < ActiveSupport::TestCase

  def single_option_custom_field
    @single_option_custom_field ||= gobierto_common_custom_fields(:madrid_custom_field_country)
  end

  def indicators_plugin
    @indicators_plugin ||= gobierto_common_custom_fields(:madrid_custom_field_indicators_plugin)
  end

  def subject
    @subject ||= gobierto_common_custom_fields(:madrid_custom_field_country)
  end

  def test_valid
    assert subject.valid?
  end

  def test_has_vocabulary?
    refute single_option_custom_field.has_vocabulary?
    assert indicators_plugin.has_vocabulary?
  end

end
