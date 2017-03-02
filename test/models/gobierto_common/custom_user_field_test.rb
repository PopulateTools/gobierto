require "test_helper"

class GobiertoCommon::CustomUserFieldTest < ActiveSupport::TestCase
  def subject
    @subject ||= GobiertoCommon::CustomUserField.new
  end

  def test_localized_title
    subject.title = { 'en' => 'title en', 'es' => 'title es' }
    assert_equal 'title en', subject.localized_title
  end
end
