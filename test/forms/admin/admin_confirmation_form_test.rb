require "test_helper"

class Admin::AdminConfirmationFormTest < ActiveSupport::TestCase
  def valid_admin_confirmation_form
    @valid_admin_confirmation_form ||= Admin::AdminNewPasswordForm.new(
      email: admin.email
    )
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_validation
    assert valid_admin_confirmation_form.valid?
  end

  def test_save
    assert valid_admin_confirmation_form.save
  end
end
