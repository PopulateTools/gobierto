require "test_helper"

class Admin::AdminUpdateTest < ActionDispatch::IntegrationTest
  def regular_admin
    @regular_admin ||= admins(:tony)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def god_admin
    @god_admin ||= admins(:natasha)
  end

  def test_regular_admin_update
    with_signed_in_admin(manager_admin) do
      visit edit_admin_admin_path(regular_admin)

      within "form.edit_admin" do
        fill_in "admin_name", with: "Admin Name"
        fill_in "admin_email", with: "wadus@gobierto.dev"
        fill_in "admin_password", with: "adminpassword"
        fill_in "admin_password_confirmation", with: "adminpassword"

        within ".site-module-check-boxes" do
          check "Gobierto Development"
        end

        within ".site-check-boxes" do
          check "madrid.gobierto.dev"
        end

        within ".admin-authorization-level-radio-buttons" do
          choose "Regular"
        end

        click_button "Update Admin"
      end

      assert has_content?("Admin was successfully updated.")

      within "table.admin-list tbody tr#admin-item-#{regular_admin.id}" do
        assert has_content?("Admin Name")
        assert has_content?("wadus@gobierto.dev")

        click_link "Admin Name"
      end

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

  def test_manager_admin_update
    with_signed_in_admin(manager_admin) do
      visit edit_admin_admin_path(manager_admin)

      within "form.edit_admin" do
        fill_in "admin_name", with: "Admin Name"

        within ".site-module-check-boxes" do
          check "Gobierto Development"
        end

        refute has_selector?(".site-check-boxes")

        within ".admin-authorization-level-radio-buttons" do
          choose "Manager"
        end

        click_button "Update Admin"
      end

      assert has_content?("Admin was successfully updated.")

      within "table.admin-list tbody tr#admin-item-#{manager_admin.id}" do
        assert has_content?("Admin Name")
        assert has_content?(manager_admin.email)

        click_link "Admin Name"
      end

      within ".admin-authorization-level-radio-buttons" do
        assert has_checked_field?("Manager")
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

        click_button "Update Admin"
      end

      assert has_content?("You are not authorized to perform this action.")
    end
  end
end
