# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminGroupCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = new_admin_admin_group_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def richard
      @richard ||= gobierto_people_people(:richard)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def test_regular_admin_create
      with_signed_in_admin(regular_admin) do
        visit @path

        assert has_no_selector?("form.new_admin_group")
      end
    end

    def test_admin_group_create
      with_javascript do
        with_signed_in_admin(admin) do
          visit @path

          within "form.new_admin_group" do
            fill_in "admin_group_name", with: "New Admin Group"

            # grant permissions for Gobierto Budgets
            find("label[for='admin_group_modules_gobiertobudgets']").click

            click_button "Create"
          end

          assert has_message?("Admins Group was successfully created")

          assert has_content?("New Admin Group")

          click_link "New Admin Group"

          # assert GobiertoBudgets is checked
          assert find("#admin_group_modules_gobiertobudgets", visible: false).checked?
        end
      end
    end

    def test_create_admin_group_with_custom_permissions
      with_javascript do
        with_signed_in_admin(admin) do
          visit @path

          fill_in "admin_group_name", with: "Another Admin Group"

          # grant permissions for Gobierto People
          find("label[for='admin_group_modules_gobiertopeople']").click

          # grant permissions for Richard Rider
          find("label[for='admin_group_people_#{richard.id}']", visible: false).trigger(:click)

          # grant permissions for Templates
          find("label[for='admin_group_site_options_templates']").click

          click_button "Create"

          assert has_message?("Admins Group was successfully created")
        end
      end

      new_admin_group = ::GobiertoAdmin::AdminGroup.last
      permissions = new_admin_group.permissions
      module_permission = new_admin_group.modules_permissions.first
      person_permission = new_admin_group.site_people_permissions.first
      site_option_permission = new_admin_group.site_options_permissions.first

      # assert total permissions

      assert_equal 3, permissions.size

      # assert module permissions

      assert_equal "site_module", module_permission.namespace
      assert_nil module_permission.resource_id
      assert_equal "manage", module_permission.action_name

      # assert person permissions

      assert_equal "gobierto_people", person_permission.namespace
      assert_equal richard.id, person_permission.resource_id
      assert_equal "manage", person_permission.action_name

      # assert site options permissions

      assert_equal "site_options", site_option_permission.namespace
      assert_equal "templates", site_option_permission.resource_name
      assert_equal "manage", site_option_permission.action_name
    end
  end
end
