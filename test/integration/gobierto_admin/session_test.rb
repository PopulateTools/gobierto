# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SessionTest < ActionDispatch::IntegrationTest
    def setup
      super
      @sign_in_path = new_admin_sessions_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_sign_in
      visit @sign_in_path

      fill_in :session_email, with: admin.email
      fill_in :session_password, with: "gobierto"

      click_button "Send"

      assert has_message?("Signed in successfully")

      click_link "admin-sign-out"

      assert has_message?("We need you to sign in to continue")
    end

    def test_invalid_sign_in
      visit @sign_in_path

      fill_in :session_email, with: admin.email
      fill_in :session_password, with: "wadus"

      click_button "Send"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end

    def test_disabled_sign_in
      visit @sign_in_path

      admin.disabled!

      fill_in :session_email, with: admin.email
      fill_in :session_password, with: "gobierto"

      click_button "Send"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end

    def test_sign_in_when_already_signed_in
      with_signed_in_admin(admin) do
        visit @sign_in_path

        assert has_message?("You are already signed in")
      end
    end
  end
end
