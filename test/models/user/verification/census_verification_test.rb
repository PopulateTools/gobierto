require "test_helper"

class User::Verification::CensusVerificationTest < ActiveSupport::TestCase
  def user_verification
    @user_verification ||= user_census_verifications(:dennis_verified)
  end

  def test_valid
    assert user_verification.valid?
  end

  def test_document_number_getter
    assert_equal "00000000A", user_verification.document_number
  end

  def test_date_of_birth_getter
    assert_equal "1992-01-01", user_verification.date_of_birth
  end
end
