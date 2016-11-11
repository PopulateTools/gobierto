require "test_helper"

class Admin::AdminFormTest < ActiveSupport::TestCase
  def valid_admin_form
    @valid_admin_form ||= Admin::AdminForm.new(
      name: admin.name,
      email: new_admin_email, # To ensure uniqueness
      password: "gobierto"
    )
  end

  def invalid_admin_form
    @invalid_admin_form ||= Admin::AdminForm.new(
      name: nil,
      email: nil,
      password: nil
    )
  end

  def admin
    @admin ||= admins(:tony)
  end

  def new_admin_email
    "wadus@gobierto.dev"
  end

  def test_save_with_valid_attributes
    assert valid_admin_form.save
  end

  def test_error_messages_with_invalid_attributes
    invalid_admin_form.save

    assert_equal 1, invalid_admin_form.errors.messages[:name].size
    assert_equal 2, invalid_admin_form.errors.messages[:email].size
    assert_equal 1, invalid_admin_form.errors.messages[:password].size
  end
end
