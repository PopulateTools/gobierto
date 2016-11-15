require "test_helper"

class Admin::AdminNewPasswordFormTest < ActiveSupport::TestCase
  def valid_admin_new_password_form
    @valid_admin_new_password_form ||= Admin::AdminNewPasswordForm.new(
      email: admin.email
    )
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_validation
    assert valid_admin_new_password_form.valid?
  end

  def test_save
    assert valid_admin_new_password_form.save
  end
end
