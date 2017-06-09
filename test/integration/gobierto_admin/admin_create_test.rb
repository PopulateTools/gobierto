require "test_helper"

module GobiertoAdmin
  class AdminCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = new_admin_admin_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def test_regular_admin_create
      with_signed_in_admin(regular_admin) do
        visit @path

        refute has_selector?("form.new_admin")
      end
    end

    def test_admin_create_and_admin_accept_email
      with_signed_in_admin(admin) do
        visit @path

        within "form.new_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "admin@email.dev"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          within ".site-check-boxes" do
            check "madrid.gobierto.dev"
          end

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          click_button "Create"
        end

        assert has_message?("Admin was successfully created")

        within "table.admin-list tbody tr", match: :first do
          assert has_content?("Admin Name")
          assert has_content?("admin@email.dev")

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

        invite_email = ActionMailer::Base.deliveries.last
        assert_equal 'admin@email.dev', invite_email.to[0]
      end

      open_email('admin@email.dev')
      current_email.click_link current_email.first('a').text

      assert has_message?("Signed in successfully")

      assert has_content?("Edit your data")

      assert has_field?("admin_email", with: "admin@email.dev")
      fill_in :admin_password, with: 'gobierto'
      fill_in :admin_password_confirmation, with: 'gobierto'
      click_button "Update"

      assert has_message?("Data updated successfully")
    end

    def test_admin_create_no_modules
      with_signed_in_admin(admin) do
        visit @path

        within "form.new_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "admin@email.dev"

          within ".site-check-boxes" do
            check "madrid.gobierto.dev"
          end

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          click_button "Create"
        end

        assert has_content?("Modules is too short (minimum at least 1 element)")
      end
    end

    def test_admin_create_no_sites
      with_signed_in_admin(admin) do
        visit @path

        within "form.new_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "admin@email.dev"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          click_button "Create"
        end

        assert has_content?("Sites is too short (minimum at least 1 element)")
      end
    end

  end
end
