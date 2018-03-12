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

  def test_registration
    with_current_site(site) do
      visit @registration_path

      within "form#user-registration-form.new_user_registration" do
        within "label" do
          within "span.indication" do
            assert has_content?("Required")
          end
        end
      end

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

  def test_registration_with_registered_user
    with_current_site(site) do
      visit @registration_path

      fill_in :user_registration_email, with: user.email

      click_on "Let's go"

      assert has_message?("That email is already registered. Try login in or recovering your password")
    end
  end

  def test_registration_with_registered_user_in_other_site
    with_current_site(other_site) do
      visit @registration_path

      fill_in :user_registration_email, with: user.email

      click_on "Let's go"

      assert has_message?("Please check your inbox to confirm your email address")
    end
  end
end
