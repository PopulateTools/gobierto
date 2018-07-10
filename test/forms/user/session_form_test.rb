# frozen_string_literal: true

require "test_helper"

class User::SessionFormTest < ActiveSupport::TestCase
  def valid_user_session_form
    @valid_user_session_form ||= User::SessionForm.new(
      email: confirmed_user.email,
      password: "gobierto",
      referrer_url: "http://example.com/home",
      site: confirmed_user.site
    )
  end

  def invalid_user_session_form
    @invalid_user_session_form ||= User::SessionForm.new(
      email: nil,
      password: nil,
      site: nil
    )
  end

  def confirmed_user
    @confirmed_user ||= users(:dennis)
  end

  def test_validation
    assert valid_user_session_form.valid?
  end

  def test_save
    assert valid_user_session_form.save
  end

  def test_error_messages_with_invalid_attributes
    invalid_user_session_form.save

    assert_equal 1, invalid_user_session_form.errors.messages[:email].size
    assert_equal 1, invalid_user_session_form.errors.messages[:password].size
    assert_equal 1, invalid_user_session_form.errors.messages[:site].size
  end
end
