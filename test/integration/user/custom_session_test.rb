# frozen_string_literal: true

require "test_helper"

class User::CustomSessionTest < ActionDispatch::IntegrationTest
  include SiteConfigHelpers

  def site_without_auth_strategy
    @site ||= sites("madrid")
  end

  def site_with_auth_strategy
    @site_with_auth_strategy ||= sites("cortegada")
  end

  def admin
    @admin ||= gobierto_admin_admins(:nick)
  end

  def user
    @user ||= users("dennis")
  end

  def activate_null_strategy_for_site(site)
    with_auth_modules_for_domains(nil) do
      with_signed_in_admin(admin) do
        visit edit_admin_site_path(site)
        within ".auth-module-check-boxes" do
          check "Null Strategy"
        end

        within ".widget_save" do
          choose "Published"
        end
        click_button "Update"
      end
    end
  end

  def test_site_normal_session_without_strategy
    with_current_site(site_without_auth_strategy) do
      visit new_user_sessions_path
      assert has_content?("Are you already registered? Log in")

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Log in"

      assert has_message?("Signed in successfully")

      within "header .user_links" do
        click_on "Sign out"
      end

      assert has_message?("Signed out successfully")
    end
  end

  def test_site_custom_session_with_strategy
    with_current_site(site_with_auth_strategy) do
      visit new_user_sessions_path

      assert has_content?("Sign in (Null strategy)")

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Submit"

      refute has_message?("Signed in successfully")

      assert has_message?("Invalid data received. The session could not be created")
    end
  end

  def test_site_configuration_strategy_change
    with_current_site(site_without_auth_strategy) do
      visit new_user_sessions_path
      assert has_content?("Are you already registered? Log in")
    end

    activate_null_strategy_for_site(site_without_auth_strategy)
    reloaded_site = Site.find(site_without_auth_strategy.id)

    with_current_site(reloaded_site) do
      visit new_user_sessions_path
      assert has_content?("Sign in (Null strategy)")
    end
  end

end
