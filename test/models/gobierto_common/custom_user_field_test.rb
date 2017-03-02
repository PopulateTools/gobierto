require "test_helper"

class GobiertoCommon::CustomUserFieldTest < ActiveSupport::TestCase
  def custom_user_field
    @custom_user_field ||= GobiertoCommon::CustomUserField.new
  end

  def test_valid
    assert custom_user_field.valid?
  end
end
