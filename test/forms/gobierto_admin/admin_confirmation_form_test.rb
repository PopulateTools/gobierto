require "test_helper"

module GobiertoAdmin
  class AdminConfirmationFormTest < ActiveSupport::TestCase
    def valid_admin_confirmation_form
      @valid_admin_confirmation_form ||= AdminConfirmationForm.new(
        email: admin.email
      )
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_validation
      assert valid_admin_confirmation_form.valid?
    end

    def test_save
      assert valid_admin_confirmation_form.save
    end

    def test_confirmation_email_delivery
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        valid_admin_confirmation_form.save
      end
    end
  end
end
