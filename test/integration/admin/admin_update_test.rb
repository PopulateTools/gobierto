require "test_helper"

class Admin::AdminUpdateTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = edit_admin_admin_path(admin)
  end

  def admin
    @admin ||= admins(:nick)
  end

  def test_site_update
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

      within "table.admin-list tbody tr#admin-item-#{admin.id}" do
        assert has_content?("Admin Name")
        assert has_content?(admin.email) # Email field can't be updated this way
      end
    end
  end
end
