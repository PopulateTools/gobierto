require "test_helper"

class GobiertoCommon::CustomUserFieldRecordTest < ActiveSupport::TestCase
  def custom_user_field_record
    @custom_user_field_record ||= GobiertoCommon::CustomUserFieldRecord.new
  end

  def test_valid
    assert custom_user_field_record.valid?
  end
end
