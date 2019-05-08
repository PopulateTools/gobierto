# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class DirtyFormsTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = edit_admin_user_path(user)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:reed)
    end

    def site
      @site ||= user.site
    end

    def test_dirty_forms
      with_javascript do
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.edit_user" do
              sleep 1

              fill_in "user_name", with: "User Name"

              click_link "Change password"

              assert_equal(
                "You have unsaved changes. Are you sure you want to leave this page?",
                page.driver.browser.switch_to.alert.text
              )

              page.accept_alert
            end
          end
        end
      end
    end
  end
end
