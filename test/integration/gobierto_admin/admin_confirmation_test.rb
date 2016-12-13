require "test_helper"

module GobiertoAdmin
  class AdminConfirmationTest < ActionDispatch::IntegrationTest
    def setup
      super
      @confirmation_path = new_admin_admin_confirmations_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_confirmation_request
      visit @confirmation_path

      fill_in :admin_confirmation_email, with: admin.email

      click_button "Request instructions"

      assert has_message?("Please, check your inbox to get instructions")
    end

    def test_invalid_confirmation_request
      visit @confirmation_path

      fill_in :admin_confirmation_email, with: "wadus@gobierto.dev"

      click_button "Request instructions"

      assert has_message?("The email address specified doesn't seem to be valid")
    end

    def test_confirmation_request_when_already_signed_in
      with_signed_in_admin(admin) do
        visit @confirmation_path

        assert has_message?("You are already signed in")
      end
    end
  end
end
