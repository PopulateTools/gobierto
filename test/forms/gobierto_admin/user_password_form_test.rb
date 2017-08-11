# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UserPasswordFormTest < ActiveSupport::TestCase
    def valid_user_password_form
      @valid_user_password_form ||= UserPasswordForm.new(
        id: user.id,
        password: "wadus",
        password_confirmation: "wadus"
      )
    end

    def invalid_user_password_form
      @invalid_user_password_form ||= UserPasswordForm.new(
        password: nil
      )
    end

    def user
      @user ||= users(:reed)
    end

    def test_save_with_valid_attributes
      assert valid_user_password_form.save
    end

    def test_save_with_invalid_attributes
      refute invalid_user_password_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_user_password_form.save

      assert_equal 1, invalid_user_password_form.errors.messages[:password].size
    end
  end
end
