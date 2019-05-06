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
      with(js: true) do
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.edit_user" do
              sleep 2

              fill_in "user_name", with: "User Name"

              click_link "Change password"

              assert_equal(
                "You have unsaved changes. Are you sure you want to leave this page?",
                page.driver.browser.modal_message
              )

              click_button "Update"

              refute page.driver.browser.modal_message
            end
          end
        end
      end
    end
  end
end
