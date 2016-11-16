require "test_helper"

class User::ConfirmationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @confirmation_path = new_user_confirmations_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_confirmation_request
    with_current_site(site) do
      visit @confirmation_path

      fill_in :user_confirmation_email, with: user.email

      click_on "Send"

      assert has_content?("Please check your inbox to get instructions.")
    end
  end

  def test_invalid_confirmation_request
    with_current_site(site) do
      visit @confirmation_path

      fill_in :user_confirmation_email, with: "wadus@gobierto.dev"

      click_on "Send"

      assert has_content?("The email address specified doesn't seem to be valid.")
    end
  end
end
