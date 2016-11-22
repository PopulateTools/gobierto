require "test_helper"

class User::CensusVerificationFormTest < ActiveSupport::TestCase
  def valid_census_verification_form
    @valid_census_verification_form ||= User::CensusVerificationForm.new(
      site_id: site.id,
      user_id: user.id,
      document_number: user_verification.document_number,
      date_of_birth: user_verification.date_of_birth,
      creation_ip: IPAddr.new("0.0.0.0")
    )
  end

  def user
    @user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def user_verification
    @user_verification ||= user_census_verifications(:dennis_verified)
  end

  def test_validation
    assert valid_census_verification_form.valid?
  end

  def test_save
    assert valid_census_verification_form.save
  end

  def test_census_verification_creation
    assert_difference "User::Verification::CensusVerification.count", 1 do
      valid_census_verification_form.save
    end
  end

  def test_user_update
    valid_census_verification_form.stub(:verified?, true) do
      valid_census_verification_form.save

      assert valid_census_verification_form.user.verified?
    end
  end
end
