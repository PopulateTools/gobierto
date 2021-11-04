# frozen_string_literal: true

require "test_helper"

class User::SessionTest < ActionDispatch::IntegrationTest
  def setup
    super
    @sign_in_path = new_user_sessions_path
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

  def other_site_user
    @other_site_user ||= users(:susan)
  end

  def privacy_page
    @privacy_page ||= gobierto_cms_pages(:privacy)
  end

  def test_sign_in_privacy_link
    site.configuration.privacy_page_id = privacy_page.id
    site.save!

    with_current_site(site) do
      visit @sign_in_path
      assert has_link?(privacy_page.title)
    end
  end

  def test_sign_in
    with_current_site(site) do
      visit @sign_in_path

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

  def test_invalid_sign_in
    with_current_site(site) do
      visit @sign_in_path

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "wadus"
      click_on "Log in"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end
  end

  def test_sign_in_when_already_signed_in
    with_current_user(user) do
      with_current_site(site) do
        visit @sign_in_path

        assert has_message?("You are already signed in.")
      end
    end
  end

  def test_sign_in_when_signed_in_in_other_site
    with_current_site(site) do
      visit @sign_in_path

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Log in"
    end

    with_current_site(other_site) do
      visit @sign_in_path

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Log in"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end

    with_current_site(site) do
      visit @sign_in_path

      assert has_message?("You are already signed in.")
    end
  end

  def test_session_is_shared_between_hosts
    with_current_site(site, include_host: true) do
      visit @sign_in_path

      fill_in :user_session_email, with: user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Log in"
    end

    # The session is replaced with the new one
    with_current_site(other_site, include_host: true) do
      visit @sign_in_path

      fill_in :user_session_email, with: other_site_user.email
      fill_in :user_session_password, with: "gobierto"
      click_on "Log in"
    end

    with_current_site(site, include_host: true) do
      visit @sign_in_path

      assert has_content?("Log in")
    end

    with_current_site(other_site, include_host: true) do
      visit @sign_in_path

      assert has_message?("You are already signed in.")
    end
  end

  def test_disabled_registration_hides_sign_in_link
     with_current_site(site_with_registration_disabled) do
      visit @sign_in_path

      assert has_no_link?("Sign in")
     end
  end
end
