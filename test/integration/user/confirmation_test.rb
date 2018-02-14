# frozen_string_literal: true

require "test_helper"

class User::ConfirmationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @confirmation_path = new_user_confirmations_path(confirmation_token: unconfirmed_user.confirmation_token)
  end

  def user
    @user ||= users(:susan)
  end

  def unconfirmed_user
    @unconfirmed_user ||= users(:charles)
  end

  def site
    @site ||= sites(:santander)
  end

  def auth_strategy_site
    @auth_strategy_site ||= sites(:cortegada)
  end

  def unconfirmed_user_in_auth_strategy_site
    @unconfirmed_user_in_auth_strategy_site ||= users(:martin)
  end

  def test_confirmation
    with_current_site(site) do
      visit @confirmation_path

      fill_in :user_confirmation_name, with: "User name"
      fill_in :user_confirmation_password, with: "wadus"
      fill_in :user_confirmation_password_confirmation, with: "wadus"
      select "1992", from: :user_confirmation_date_of_birth_1i
      select "January", from: :user_confirmation_date_of_birth_2i
      select "1", from: :user_confirmation_date_of_birth_3i

      choose "Male"

      click_on "Save"

      assert has_message?("Signed in successfully")
    end
  end

  def test_confirmation_with_password_disabled
    with_current_site(auth_strategy_site) do
      visit new_user_confirmations_path(confirmation_token: unconfirmed_user_in_auth_strategy_site.confirmation_token)

      assert has_no_field? :user_confirmation_password
      assert has_no_field? :user_confirmation_password_confirmation

      fill_in :user_confirmation_name, with: "User name"
      select "1992", from: :user_confirmation_date_of_birth_1i
      select "January", from: :user_confirmation_date_of_birth_2i
      select "1", from: :user_confirmation_date_of_birth_3i

      choose "Male"

      click_on "Save"

      assert has_message?("Signed in successfully")
    end
  end

  def test_invalid_confirmation
    with_current_site(site) do
      visit @confirmation_path

      fill_in :user_confirmation_name, with: nil

      click_on "Save"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end
  end

  def test_confirmation_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @confirmation_path

        assert has_message?("You are already signed in.")
      end
    end
  end
end
