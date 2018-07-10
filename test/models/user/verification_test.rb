# frozen_string_literal: true

require "test_helper"

class User::VerificationTest < ActiveSupport::TestCase
  def user_verification
    @user_verification ||= user_verification_census_verifications(:dennis_verified)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_valid
    assert user_verification.valid?
  end

  def test_current_by_site
    assert_equal user_verification.id, User::Verification.send(user_verification.verification_type).current_by_site(site).id
  end

  def test_verify!
    user_verification.verify!
  end

  def test_verify_later!
    assert_enqueued_with(job: User::VerificationJob, args: [user_verification], queue: "user_verifications") do
      user_verification.verify_later!
    end
  end
end
