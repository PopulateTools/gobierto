# frozen_string_literal: true

require "test_helper"
require "ladle"

class User::CustomSessionTest < ActionDispatch::IntegrationTest
  include SiteConfigHelpers

  def setup
    super
    site.configuration.raw_configuration_variables = ldap_configuration.deep_stringify_keys.to_yaml
    site.save

    @ldap_server = Ladle::Server.new(
      **ldap_server_configuration.slice(:domain, :port, :host).merge(
        quiet: true
      )
    ).start
    site.configuration.auth_modules = %w(ldap_strategy)
  end

  def teardown
    super

    @ldap_server&.stop
  end

  def ldap_user_credentials
    @ldap_user_credentials ||= {
      email: "belle@example.org",
      password: "niwdlab",
      name: "Belle Baldwin"
    }
  end

  def ldap_configuration
    @ldap_configuration ||= {
      ldap: {
        ldap_username: "uid=aa729,ou=people,dc=example,dc=org",
        ldap_password: "smada",
        configurations: [ldap_server_configuration]
      }
    }
  end

  def ldap_server_configuration
    @ldap_server_configuration ||= {
      host: "127.0.0.1",
      port: "3897",
      domain: "dc=example,dc=org",
      authentication_query: "mail=%{user_identifier}",
      email_field: "mail",
      password_field: "userpassword",
      name_field: "cn"
    }
  end

  def site
    @site ||= sites("cortegada")
  end

  def user
    @user ||= users("martin")
  end

  def secrets
    Rails.application.secrets
  end

  def test_valid_ldap_not_existing_user
    with(site: site) do
      visit new_user_sessions_path

      assert has_content?("Sign in")

      assert_difference "User.count", 1 do
        fill_in :user_session_email, with: ldap_user_credentials[:email]
        fill_in :user_session_password, with: ldap_user_credentials[:password]
        click_on "Submit"

        assert has_message?("Signed in successfully")
      end
    end
  end

  def test_valid_ldap_existing_user
    ldap_user = site.users.create(ldap_user_credentials.except(:password))
    ldap_user.confirm!
    with(site: site) do
      visit new_user_sessions_path

      assert has_content?("Sign in")

      assert_no_difference "User.count" do
        fill_in :user_session_email, with: ldap_user_credentials[:email]
        fill_in :user_session_password, with: ldap_user_credentials[:password]
        click_on "Submit"
      end
      assert has_message?("Signed in successfully")
    end
  end

  def test_invalid_ldap_existing_confirmed_user
    user.confirm!
    with(site: site) do
      visit new_user_sessions_path

      assert has_content?("Sign in")

      assert_no_difference "User.count" do
        fill_in :user_session_email, with: user.email
        fill_in :user_session_password, with: "gobierto"
        click_on "Submit"

      end
      assert has_message?("Signed in successfully")
    end
  end

  def test_valid_ldap_existing_unconfirmed_user
    user = site.users.create(ldap_user_credentials.except(:password))
    user.regenerate_confirmation_token
    refute user.confirmed?

    with(site: site) do
      visit new_user_sessions_path

      assert has_content?("Sign in")

      assert_no_difference "User.count" do
        fill_in :user_session_email, with: ldap_user_credentials[:email]
        fill_in :user_session_password, with: ldap_user_credentials[:password]
        click_on "Submit"
      end
      assert has_message?("Signed in successfully")
    end

    user.reload
    assert user.confirmed?
  end

  def test_invalid_ldap_existing_user_invalid_password
    with(site: site) do
      visit new_user_sessions_path

      assert has_content?("Sign in")

      assert_no_difference "User.count" do
        fill_in :user_session_email, with: user.email
        fill_in :user_session_password, with: "wadus"
        click_on "Submit"

      end
      assert has_no_content?("Signed in successfully")
    end
  end
end
