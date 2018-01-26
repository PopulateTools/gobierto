# frozen_string_literal: true

require "test_helper"

class User::Verification::CensusVerificationTest < ActiveSupport::TestCase
  def user_verification
    @user_verification ||= user_verification_census_verifications(:dennis_verified)
  end

  def unverified_user_verification
    @unverified_user_verification ||= user_verification_census_verifications(:reed_unverified)
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

  def test_will_verify?
    assert user_verification.will_verify?
  end

  def test_verify!
    refute unverified_user_verification.verified?
    refute unverified_user_verification.user.census_verified?
    refute_equal user_verification.user.site, unverified_user_verification.site

    unverified_user_verification.stub(:will_verify?, true) do
      unverified_user_verification.verify!

      assert unverified_user_verification.reload.verified?
      assert unverified_user_verification.user.reload.census_verified?
      assert_equal unverified_user_verification.user.site, unverified_user_verification.site
    end
  end
end
