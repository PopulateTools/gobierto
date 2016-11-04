require "test_helper"

class Admin::SessionTest < ActionDispatch::IntegrationTest
  def setup
    super
    @sign_in_path = new_admin_sessions_path
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_sign_in
    visit @sign_in_path

    fill_in :session_email, with: admin.email
    fill_in :session_password, with: "gobierto"
    click_on "Log in"

    assert has_content?("Signed in successfully.")

    click_on "Sign out"

    assert has_content?("We need you to sign in to continue.")
  end

  def test_invalid_sign_in
    visit @sign_in_path

    fill_in :session_email, with: admin.email
    fill_in :session_password, with: "wadus"
    click_on "Log in"

    assert has_content?("The data you entered doesn't seem to be valid. Please try again.")
  end
end
