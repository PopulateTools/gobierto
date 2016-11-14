require "test_helper"

class Admin::AdminUpdateTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = edit_admin_admin_path(managed_admin)
  end

  def admin
    @admin ||= admins(:nick)
  end

  def managed_admin
    @managed_admin ||= admins(:steve)
  end

  def test_admin_update
    with_signed_in_admin(admin) do
      visit @path

      within "form.edit_admin" do
        fill_in "admin_name", with: "Admin Name"

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

      within "table.admin-list tbody tr#admin-item-#{managed_admin.id}" do
        assert has_content?("Admin Name")
        assert has_content?(managed_admin.email) # The email field can't be updated this way

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
end
