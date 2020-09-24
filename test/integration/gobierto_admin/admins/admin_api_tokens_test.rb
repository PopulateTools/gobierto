# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminApiTokensTest < ActionDispatch::IntegrationTest

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def primary_token
      @primary_token ||= gobierto_admin_api_tokens(:tony_primary_api_token)
    end

    def secondary_token
      @secondary_token ||= gobierto_admin_api_tokens(:tony_domain)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_manager_admin_manage_admin_api_tokens
      with(admin: manager_admin) do
        visit edit_admin_admin_path(regular_admin)

        within "#api_tokens" do
          assert has_content?("API Tokens")

          within "table tbody" do
            within("tr", match: :first) do
              assert has_content?(primary_token.token)
              assert has_content?("Primary")
              assert has_no_selector?("a[data-method='delete']")
            end

            within "#api_token-#{secondary_token.id}" do
              assert has_content?(secondary_token.token)
              assert has_selector?("a[data-method='delete']")
            end
          end
        end
      end
    end

    def test_create_api_token_errors
      with(admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        within "#api_tokens" do
          click_link "New"
        end

        fill_in "api_token_name", with: "New token"
        fill_in "api_token_domain", with: "invalid domain name"

        click_button "Create"

        assert has_alert?("Domain Invalid format")

        visit edit_admin_admin_path(regular_admin)
        within "#api_tokens" do
          within "table tbody" do
            assert has_no_content?("New token")
          end
        end
      end
    end

    def test_create_api_token
      with(admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        within "#api_tokens" do
          click_link "New"
        end

        fill_in "api_token_name", with: "New token"
        fill_in "api_token_domain", with: "www.organization.com"

        click_button "Create"

        assert has_message?("API Token was successfully created")

        within "#api_tokens" do
          within "table tbody" do
            assert has_content?("New token")
            assert has_content?("www.organization.com")
          end
        end
      end
    end

    def test_update_primary_api_token
      initial_token_content = primary_token.token

      with(admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        find(:xpath, %(//a[@href="#{edit_admin_admin_api_token_path(regular_admin, primary_token)}"])).click

        within "#edit_api_token" do
          fill_in "api_token_name", with: "Updated primary token"
          fill_in "api_token_domain", with: "www.primary-token.com"

          click_button "Update"
        end

        assert has_message?("API Token was successfully updated")

        primary_token.reload

        assert_equal initial_token_content, primary_token.token
        within "#api_tokens" do
          within "table tbody" do
            within("tr", match: :first) do
              assert has_content?("Updated primary token")
              assert has_content?("www.primary-token.com")
              assert has_content?(initial_token_content)
            end
          end
        end
      end
    end

    def test_update_primary_api_token_content
      initial_token_content = primary_token.token

      with(admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        find(:xpath, %(//a[@href="#{edit_admin_admin_api_token_path(regular_admin, primary_token)}"])).click

        within "#edit_api_token" do
          fill_in "api_token_name", with: "Updated primary token"
          fill_in "api_token_domain", with: "www.primary-token.com"
          find("label[for='api_token_update_token']", visible: false).execute_script("this.click()")

          click_button "Update"
        end

        assert has_message?("API Token was successfully updated")

        primary_token.reload

        refute_equal initial_token_content, primary_token.token
        within "#api_tokens" do
          within "table tbody" do
            within("tr", match: :first) do
              assert has_content?("Updated primary token")
              assert has_content?("www.primary-token.com")
              assert has_no_content?(initial_token_content)
              assert has_content?(primary_token.token)
            end
          end
        end
      end
    end

    def test_delete_secondary_api_token
      token_id = secondary_token.id
      with(admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        within "#api_tokens" do
          within "#api_token-#{token_id}" do
            find("a[data-method='delete']").click
          end
        end

        page.accept_alert

        assert has_message?("API Token deleted successfully")
        refute regular_admin.api_tokens.exists?(id: token_id)
      end
    end
  end
end
