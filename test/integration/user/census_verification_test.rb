# frozen_string_literal: true

require "test_helper"

class User::CensusVerificationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @verification_path = new_user_census_verifications_path
  end

  def unverified_user
    @unverified_user ||= users(:susan)
  end

  def verified_user
    @verified_user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_successful_verification
    with_signed_in_user(unverified_user) do
      visit @verification_path

      fill_in :user_verification_document_number, with: " 00*00 00ñ00 a "

      click_on "Verify"

      assert has_content?("Your identity has been verified successfully")
    end
  end

  def test_invalid_verification_no_data
    with_signed_in_user(unverified_user) do
      visit @verification_path

      fill_in :user_verification_document_number, with: nil

      click_on "Verify"

      assert has_content?("Confirm your identity")
      assert has_content?("We couldn't verify your identity. Please check your information and try again. If the problem persists, ask to your local adminsitration")
    end
  end

  def test_failed_verification
    with_signed_in_user(unverified_user) do
      visit @verification_path

      fill_in :user_verification_document_number, with: "00000000P"

      select "1990", from: :user_verification_date_of_birth_1i
      select "October", from: :user_verification_date_of_birth_2i
      select "19", from: :user_verification_date_of_birth_3i

      click_on "Verify"

      assert has_content?("Confirm your identity")
    end
  end

  def test_verification_when_already_verified
    with_signed_in_user(verified_user) do
      visit @verification_path

      assert has_content?("Your account is already verified")
    end
  end
end
