require "test_helper"

class Admin::AdminEditPasswordFormTest < ActiveSupport::TestCase
  def valid_admin_edit_password_form
    @valid_admin_edit_password_form ||= Admin::AdminEditPasswordForm.new(
      admin_id: admin.id,
      password: "wadus",
      password_confirmation: "wadus"
    )
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_validation
    assert valid_admin_edit_password_form.valid?
  end

  def test_save
    assert valid_admin_edit_password_form.save
  end
end
