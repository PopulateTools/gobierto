# frozen_string_literal: true

require "test_helper"

class User::PasswordResetTest < ActionDispatch::IntegrationTest
  def setup
    super
    @password_request_path = new_user_sessions_path
    @password_change_path = edit_user_passwords_path(reset_password_token: recoverable_user.reset_password_token)
  end

  def user
    @user ||= users(:dennis)
  end

  def other_site_user
    @other_site_user ||= users(:charles)
  end

  def recoverable_user
    @recoverable_user ||= users(:dennis)
  end

  def confirmable_user
    @confirmable_user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_password_reset_request
    with_current_site(site) do
      visit @password_request_path

      fill_in :user_password_email, with: user.email

      click_button "Recover"

      assert has_message?("Please check your inbox to get instructions")
    end
  end

  def test_invalid_password_reset_request
    with_current_site(site) do
      visit @password_request_path

      fill_in :user_password_email, with: "wadus@gobierto.dev"

      click_button "Recover"

      assert has_message?("The email address specified doesn't seem to be valid")
    end
  end

  def test_password_reset_request_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @password_request_path

        assert has_message?("You are already signed in.")
      end
    end
  end

  def test_password_change
    with_current_site(site) do
      visit @password_change_path

      fill_in :user_password_password, with: "wadus"
      fill_in :user_password_password_confirmation, with: "wadus"

      click_button "Change"

      assert has_message?("Signed in successfully")
    end
  end

  def test_invalid_password_change
    with_current_site(site) do
      visit @password_change_path

      fill_in :user_password_password, with: "wadus"
      fill_in :user_password_password_confirmation, with: "foo"

      click_button "Change"

      assert has_message?("There was a problem changing your password")
    end
  end

  def test_password_change_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @password_change_path

        assert has_message?("You are already signed in.")
      end
    end
  end

  def test_confirmation_request
    with_current_site(site) do
      visit @password_request_path

      fill_in :user_password_email, with: confirmable_user.email

      click_on "Recover"

      assert has_message?("Please check your inbox to get instructions")
    end
  end

  def test_password_reset_request_from_other_site_user
    with_current_site(site) do
      visit @password_request_path

      fill_in :user_password_email, with: other_site_user.email

      click_button "Recover"

      assert has_message?("The email address specified doesn't seem to be valid")
    end
  end
end
