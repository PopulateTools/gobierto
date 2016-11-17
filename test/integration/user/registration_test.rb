require "test_helper"

class User::RegistrationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @registration_path = new_user_registrations_path
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
      fill_in :user_registration_name, with: "User Name"
      fill_in :user_registration_password, with: "gobierto"
      fill_in :user_registration_password_confirmation, with: "gobierto"

      click_on "Sign up"

      assert has_content?("Please check your inbox for confirmation.")
    end
  end

  def test_invalid_registration
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: nil
      fill_in :user_registration_name, with: nil
      fill_in :user_registration_password, with: "gobierto"
      fill_in :user_registration_password_confirmation, with: "wadus"

      click_on "Sign up"

      assert has_content?("The data you entered doesn't seem to be valid. Please try again.")
    end
  end
end
