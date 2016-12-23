require "test_helper"

module GobiertoAdmin
  class UserWelcomeMessageFormTest < ActiveSupport::TestCase
    def valid_welcome_message_form
      @valid_welcome_message_form ||= UserWelcomeMessageForm.new(
        id: user.id
      )
    end

    def user
      @user ||= users(:reed)
    end

    def test_save_with_valid_attributes
      assert valid_welcome_message_form.save
    end

    def test_welcome_email_delivery
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        valid_welcome_message_form.save
      end
    end
  end
end
