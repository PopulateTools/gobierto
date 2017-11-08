# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UserFormTest < ActiveSupport::TestCase
    def valid_user_form
      @valid_user_form ||= UserForm.new(
        id: user.id,
        name: user.name,
        bio: user.bio,
        email: user.email
      )
    end

    def invalid_user_form
      @invalid_user_form ||= UserForm.new(
        name: nil,
        email: nil
      )
    end

    def user
      @user ||= users(:reed)
    end

    def test_save_with_valid_attributes
      assert valid_user_form.save
    end

    def test_save_with_invalid_attributes
      refute invalid_user_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_user_form.save

      assert_equal 1, invalid_user_form.errors.messages[:name].size
      assert_equal 1, invalid_user_form.errors.messages[:email].size
    end

    def test_confirmation_email_delivery_when_changing_email
      email_changing_form = UserForm.new(
        id: user.id,
        email: "wadus@gobierto.dev",
        name: "Wadus"
      )

      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        email_changing_form.save
      end
    end

    def test_confirmation_email_delivery_when_not_changing_email
      assert_no_difference "ActionMailer::Base.deliveries.size" do
        valid_user_form.save
      end
    end
  end
end
