# frozen_string_literal: true

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

  def other_site
    @other_site ||= sites(:santander)
  end

  def site_with_registration_disabled
    @site_with_registration_disabled ||= sites(:cortegada)
  end

  def registration_ack_message
    "Please check your inbox to confirm your email address"
  end

  def test_registration
    with_current_site(site) do
      visit @registration_path

      within "form#user-registration-form.new_user_registration" do
        within "span.indication" do
          assert has_content?("Required")
        end
      end

      fill_in :user_registration_email, with: "user@email.dev"

      assert_difference "User.count", 1 do
        click_on "Let's go"
      end

      assert has_message? registration_ack_message
    end
  end

  def test_registration_as_spam
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: "spam@email.dev"
      fill_in :user_registration_ic_email, with: "spam@email.dev"

      assert_no_difference "User.count" do
        click_on "Let's go"
      end
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

  def test_registration_with_registered_user
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: user.email

      click_on "Let's go"

      assert has_message?("That email is already registered. Try login in or recovering your password")
    end
  end

  def test_registration_with_email_capitalized
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: user.email.upcase

      click_on "Let's go"

      assert has_message?("That email is already registered. Try login in or recovering your password")
    end
  end

  def test_registration_with_registered_user_in_other_site
    with_current_site(other_site) do
      visit @registration_path

      fill_in :user_registration_email, with: user.email

      click_on "Let's go"

      assert has_message? registration_ack_message
    end
  end

  def test_registration_when_site_disables_registration
    with_current_site(site_with_registration_disabled) do
      visit @registration_path

      assert has_no_content?("Create your account")
      assert has_no_button?("Let's go")
    end
  end
end
