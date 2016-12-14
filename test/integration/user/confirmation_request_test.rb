require "test_helper"

class User::ConfirmationRequestTest < ActionDispatch::IntegrationTest
  def setup
    super
    @confirmation_request_path = new_user_confirmation_requests_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_confirmation_request
    with_current_site(site) do
      visit @confirmation_request_path

      fill_in :user_confirmation_request_email, with: user.email

      click_on "Send"

      assert has_content?("Please check your inbox to get instructions.")
    end
  end

  def test_invalid_confirmation_request
    with_current_site(site) do
      visit @confirmation_request_path

      fill_in :user_confirmation_request_email, with: "wadus@gobierto.dev"

      click_on "Send"

      assert has_content?("The email address specified doesn't seem to be valid.")
    end
  end

  def test_confirmation_request_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @confirmation_request_path

        assert has_content?("You are already signed in.")
      end
    end
  end
end
