require "test_helper"

module GobiertoAdmin
  class AdminUpdateTest < ActionDispatch::IntegrationTest
    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def god_admin
      @god_admin ||= gobierto_admin_admins(:natasha)
    end

    def test_regular_admin_update
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(regular_admin)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          within ".site-check-boxes" do
            check "madrid.gobierto.dev"
          end

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          click_button "Update"
        end

        assert has_message?("Admin was successfully updated")

        within "form.edit_admin" do
          assert has_field?("admin_email", with: "wadus@gobierto.dev")
          assert has_field?("admin_name", with: "Admin Name")

          within ".site-module-check-boxes" do
            assert has_checked_field?("Gobierto Development")
            refute has_checked_field?("Gobierto Budgets")
          end

          within ".site-check-boxes" do
            assert has_checked_field?("madrid.gobierto.dev")
            refute has_checked_field?("santander.gobierto.dev")
          end

          within ".admin-authorization-level-radio-buttons" do
            assert has_checked_field?("Regular")
          end
        end
      end
    end

    def test_manager_admin_update
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(manager_admin)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_password", with: "wadus"
          fill_in "admin_password_confirmation", with: "wadus"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          refute has_selector?(".site-check-boxes")

          within ".admin-authorization-level-radio-buttons" do
            choose "Manager"
          end

          click_button "Update"
        end

        assert has_message?("Admin was successfully updated")

        within "form.edit_admin" do
          assert has_field?("admin_name", with: "Admin Name")
          assert has_field?("admin_email", with: manager_admin.email)

          within ".admin-authorization-level-radio-buttons" do
            assert has_checked_field?("Manager")
          end
        end
      end
    end

    def test_god_admin_update
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(god_admin)

        within "form.edit_admin" do
          assert has_field?("admin_name", disabled: true)
          assert has_field?("admin_email", disabled: true)

          refute has_selector?(".site-module-check-boxes")
          refute has_selector?(".site-check-boxes")
          refute has_selector?(".admin-authorization-level-radio-buttons")

          assert has_button?("Update", disabled: true)
        end
      end
    end
  end
end
