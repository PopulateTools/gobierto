require "test_helper"

class User::ConfirmationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @confirmation_path = new_user_confirmations_path(confirmation_token: unconfirmed_user.confirmation_token)
  end

  def user
    @user ||= users(:dennis)
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
      select 20.years.ago.year, from: :user_confirmation_year_of_birth
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
