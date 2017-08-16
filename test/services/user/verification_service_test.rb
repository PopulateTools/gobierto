# frozen_string_literal: true

require "test_helper"

class User::VerificationServiceTest < ActiveSupport::TestCase
  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def valid_verification_type
    "census"
  end

  def test_call
    assert User::VerificationService.new(user, site).call
    assert User::VerificationService.new(user, site, valid_verification_type).call
    refute User::VerificationService.new(user, site, "wadus").call
  end
end
