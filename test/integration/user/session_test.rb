require "test_helper"

class User::SessionTest < ActionDispatch::IntegrationTest
  def setup
    super
    @sign_in_path = new_user_sessions_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_sign_in
    with_current_site(site) do
      visit @sign_in_path

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Log in"

      assert has_message?("Signed in successfully")

      within "header .user_links" do
        click_on "Sign out"
      end

      assert has_message?("Signed out successfully")
    end
  end

  def test_invalid_sign_in
    with_current_site(site) do
      visit @sign_in_path

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "wadus"
      click_on "Log in"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end
  end

  def test_sign_in_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @sign_in_path

        assert has_message?("You are already signed in.")
      end
    end
  end
end
