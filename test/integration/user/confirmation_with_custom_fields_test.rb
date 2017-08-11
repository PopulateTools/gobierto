# frozen_string_literal: true

require "test_helper"

class User::ConfirmationWithCustomFieldsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @confirmation_path = new_user_confirmations_path(confirmation_token: unconfirmed_user.confirmation_token)
  end

  def unconfirmed_user
    @unconfirmed_user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_confirmation
    with_current_site(site) do
      visit @confirmation_path

      fill_in :user_confirmation_name, with: "user@email.dev"
      fill_in :user_confirmation_password, with: "wadus"
      fill_in :user_confirmation_password_confirmation, with: "wadus"
      select "1992", from: :user_confirmation_date_of_birth_1i
      select "January", from: :user_confirmation_date_of_birth_2i
      select "1", from: :user_confirmation_date_of_birth_3i
      choose "Male"
      fill_in :user_confirmation_document_number, with: "00000000A"
      select "Center", from: "Districts"
      fill_in "Association", with: "Asociación Vecinos Arganzuela"
      fill_in "Bio", with: "My short bio"

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

      fill_in :user_confirmation_name, with: "user@email.dev"
      fill_in :user_confirmation_password, with: "wadus"
      fill_in :user_confirmation_password_confirmation, with: "wadus"
      select "1992", from: :user_confirmation_date_of_birth_1i
      select "January", from: :user_confirmation_date_of_birth_2i
      select "1", from: :user_confirmation_date_of_birth_3i
      choose "Male"
      fill_in :user_confirmation_document_number, with: "00000000A"
      click_on "Save"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")

      fill_in :user_confirmation_password, with: "wadus"
      fill_in :user_confirmation_password_confirmation, with: "wadus"
      select "Center", from: "Districts"
      fill_in "Association", with: "Asociación Vecinos Arganzuela"

      click_on "Save"
      assert has_message?("Signed in successfully")
    end
  end

  def test_valid_confirmation_invalid_verificaction
    with_current_site(site) do
      visit @confirmation_path

      fill_in :user_confirmation_name, with: "user@email.dev"
      fill_in :user_confirmation_password, with: "wadus"
      fill_in :user_confirmation_password_confirmation, with: "wadus"
      select "1992", from: :user_confirmation_date_of_birth_1i
      select "January", from: :user_confirmation_date_of_birth_2i
      select "1", from: :user_confirmation_date_of_birth_3i
      choose "Male"
      fill_in :user_confirmation_document_number, with: "10000000A"
      select "Center", from: "Districts"
      fill_in "Association", with: "Asociación Vecinos Arganzuela"
      fill_in "Bio", with: "My short bio"

      click_on "Save"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
      assert has_content?("Census verification is invalid")

      fill_in :user_confirmation_password, with: "wadus"
      fill_in :user_confirmation_password_confirmation, with: "wadus"
      fill_in :user_confirmation_document_number, with: "00000000A"
      click_on "Save"

      assert has_message?("Signed in successfully")
    end
  end
end
