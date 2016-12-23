require "test_helper"

class User::RegistrationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @registration_path = new_user_sessions_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_registration
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: "user@email.dev"

      click_on "Let's go"

      assert has_message?("Please check your inbox to confirm your email address")
    end
  end

  def test_invalid_registration
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: nil

      click_on "Let's go"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end
  end

  def test_registration_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @registration_path

        assert has_message?("You are already signed in.")
      end
    end
  end
end
