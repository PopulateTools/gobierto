# frozen_string_literal: true

require 'test_helper'

class User::CensusVerificationFormTest < ActiveSupport::TestCase
  def valid_census_verification_form
    @valid_census_verification_form ||= User::CensusVerificationForm.new(
      site_id: site.id,
      user_id: user.id,
      document_number: user_verification.document_number,
      date_of_birth_year: date_of_birth.year,
      date_of_birth_month: date_of_birth.month,
      date_of_birth_day: date_of_birth.day,
      creation_ip: IPAddr.new('0.0.0.0')
    )
  end

  def date_of_birth
    @date_of_birth ||= Date.parse(user_verification.date_of_birth)
  end

  def user
    @user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def user_verification
    @user_verification ||= user_verification_census_verifications(:dennis_verified)
  end

  def test_validation
    assert valid_census_verification_form.valid?
  end

  def test_save
    assert valid_census_verification_form.save
  end

  def test_census_verification_creation
    assert_difference 'User::Verification::CensusVerification.count', 1 do
      valid_census_verification_form.save
    end
  end
end
