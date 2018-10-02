# frozen_string_literal: true

require "test_helper"

class GobiertoCommon::CustomFieldTest < ActiveSupport::TestCase
  def subject
    @subject ||= gobierto_common_custom_fields(:madrid_custom_field_country)
  end

  def test_valid
    assert subject.valid?
  end
end
