require "test_helper"

module GobiertoAdmin
  class AdminPasswordResetTest < ActionDispatch::IntegrationTest
    def setup
      super
      @password_request_path = new_admin_admin_passwords_path
      @password_change_path = edit_admin_admin_passwords_path(reset_password_token: admin.reset_password_token)
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_password_reset_request
      visit @password_request_path

      fill_in :admin_password_email, with: admin.email

      click_on "Send"

      assert has_message?("Please check your inbox to get instructions.")
    end

    def test_invalid_password_reset_request
      visit @password_request_path

      fill_in :admin_password_email, with: "wadus@gobierto.dev"

      click_on "Send"

      assert has_message?("The email address specified doesn't seem to be valid.")
    end

    def test_password_reset_request_when_already_signed_in
      with_signed_in_admin(admin) do
        visit @password_request_path

        assert has_message?("You are already signed in")
      end
    end

    def test_password_change
      visit @password_change_path

      fill_in :admin_password_password, with: "wadus"
      fill_in :admin_password_password_confirmation, with: "wadus"

      click_on "Send"

      assert has_message?("Signed in successfully")
    end

    def test_invalid_password_change
      visit @password_change_path

      fill_in :admin_password_password, with: "wadus"
      fill_in :admin_password_password_confirmation, with: "foo"

      click_on "Send"

      assert has_message?("There was a problem changing your password.")
    end

    def test_password_change_when_already_signed_in
      with_signed_in_admin(admin) do
        visit @password_change_path

        assert has_message?("You are already signed in")
      end
    end
  end
end
