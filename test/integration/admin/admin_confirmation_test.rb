require "test_helper"

class Admin::AdminConfirmationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @confirmation_path = new_admin_admin_confirmations_path
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_confirmation_request
    visit @confirmation_path

    fill_in :admin_confirmation_email, with: admin.email

    click_on "Send"

    assert has_content?("Please check your inbox to get instructions.")
  end

  def test_invalid_confirmation_request
    visit @confirmation_path

    fill_in :admin_confirmation_email, with: "wadus@gobierto.dev"

    click_on "Send"

    assert has_content?("The email address specified doesn't seem to be valid.")
  end
end
