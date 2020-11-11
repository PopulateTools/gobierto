# frozen_string_literal: true

require "test_helper"
require "ladle"

module GobiertoAdmin
  class CustomLdapSessionTest < ActionDispatch::IntegrationTest
    def setup
      super
      site.configuration.raw_configuration_variables = ldap_configuration.deep_stringify_keys.to_yaml
      site.save

      @ldap_server = Ladle::Server.new(
        **ldap_server_configuration.slice(:domain, :port, :host).merge(
          quiet: true
        )
      ).start
      site.configuration.admin_auth_modules = %w(ldap_strategy)
      site.save
      @sign_in_path = new_admin_sessions_path
    end

    def teardown
      super

      @ldap_server&.stop
    end

    def ldap_admin_credentials
      @ldap_admin_credentials ||= {
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
        authentication_query: "mail=@screen_name@",
        email_field: "mail",
        password_field: "userpassword",
        name_field: "cn"
      }
    end

    def site
      @site ||= sites("cortegada")
    end

    def other_site
      @other_site ||= sites("madrid")
    end

    def admin
      @admin ||= gobierto_admin_admins("nick")
    end

    def secrets
      Rails.application.secrets
    end

    def test_valid_ldap_not_existing_admin
      with_current_site(site, include_host: true) do
        visit @sign_in_path

        assert has_content?("Identifier")

        assert_difference "GobiertoAdmin::Admin.count", 1 do
          fill_in :session_identifier, with: ldap_admin_credentials[:email]
          fill_in :session_password, with: ldap_admin_credentials[:password]
          click_on "Submit"
        end

        assert has_message?("Signed in successfully")

        new_admin = GobiertoAdmin::Admin.last
        assert new_admin.regular?
        assert_equal [site], new_admin.sites
      end
    end

    def test_valid_ldap_existing_regular_admin
      ldap_admin = GobiertoAdmin::Admin.regular.create(ldap_admin_credentials.except(:password))
      ldap_admin.sites << site
      with_current_site(site, include_host: true) do
        visit @sign_in_path

        assert has_content?("Identifier")

        assert_no_difference "GobiertoAdmin::Admin.count" do
          fill_in :session_identifier, with: ldap_admin_credentials[:email]
          fill_in :session_password, with: ldap_admin_credentials[:password]
          click_on "Submit"
        end
        assert has_message?("Signed in successfully")
      end
    end

    def test_valid_ldap_existing_manager_admin
      GobiertoAdmin::Admin.manager.create(ldap_admin_credentials.except(:password))
      with_current_site(site, include_host: true) do
        visit @sign_in_path

        assert has_content?("Identifier")

        assert_no_difference "GobiertoAdmin::Admin.count" do
          fill_in :session_identifier, with: ldap_admin_credentials[:email]
          fill_in :session_password, with: ldap_admin_credentials[:password]
          click_on "Submit"
        end
        assert has_message?("Signed in successfully")
      end
    end

    def test_valid_ldap_existing_regular_admin_on_other_site
      ldap_admin = GobiertoAdmin::Admin.regular.create(ldap_admin_credentials.except(:password))
      ldap_admin.sites << other_site
      with_current_site(site, include_host: true) do
        visit @sign_in_path

        assert has_content?("Identifier")

        assert_no_difference "GobiertoAdmin::Admin.count" do
          fill_in :session_identifier, with: ldap_admin_credentials[:email]
          fill_in :session_password, with: ldap_admin_credentials[:password]
          click_on "Submit"
        end
        assert has_message?("Signed in successfully")
      end
      assert_includes ldap_admin.sites, other_site
    end

    def test_invalid_ldap_existing_admin_invalid_password
      with_current_site(site, include_host: true) do
        visit @sign_in_path

        assert has_content?("Identifier")

        assert_no_difference "User.count" do
          fill_in :session_identifier, with: ldap_admin_credentials[:email]
          fill_in :session_password, with: "wadus"
          click_on "Submit"
        end
        assert has_no_content?("Signed in successfully")
      end
    end
  end
end
