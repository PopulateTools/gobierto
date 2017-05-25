# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class AdminNewPasswordFormTest < ActiveSupport::TestCase
    def valid_admin_new_password_form
      @valid_admin_new_password_form ||= AdminNewPasswordForm.new(
        email: admin.email
      )
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_validation
      assert valid_admin_new_password_form.valid?
    end

    def test_save
      assert valid_admin_new_password_form.save
    end

    def test_reset_password_email_delivery
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        valid_admin_new_password_form.save
      end
    end
  end
end
