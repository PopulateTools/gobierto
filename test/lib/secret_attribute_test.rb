require "test_helper"

class SecretAttributeTest < Minitest::Test
  def test_digest
    subject = SecretAttribute.digest("wadus")

    assert_kind_of String, subject
    assert_equal SecretAttribute.digest("wadus"), subject
  end
end
