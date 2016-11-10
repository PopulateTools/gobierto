require "test_helper"

class Admin::AdminCreateTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = new_admin_admin_path
  end

  def admin
    @admin ||= admins(:nick)
  end

  def test_site_create
    with_signed_in_admin(admin) do
      visit @path

      within "form.new_admin" do
        fill_in "admin_name", with: "Admin Name"
        fill_in "admin_email", with: "admin@email.dev"
        fill_in "admin_password", with: "AdminPassword"

        within ".site-module-check-boxes" do
          check "Gobierto Development"
        end

        within ".site-check-boxes" do
          check "madrid.gobierto.dev"
        end

        within ".admin-authorization-level-radio-buttons" do
          choose "Regular"
        end

        click_button "Create Admin"
      end

      assert has_content?("Admin was successfully created.")

      within "table.admin-list tbody tr", match: :first do
        assert has_content?("Admin Name")
        assert has_content?("admin@email.dev")
      end
    end
  end
end
