# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminGroupUpdateTest < ActionDispatch::IntegrationTest

    def tony
      @tony ||= gobierto_admin_admins(:tony)
    end
    alias regular_admin tony

    def steve
      @steve ||= gobierto_admin_admins(:steve)
    end
    alias regular_admin_on_santander steve

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def god_admin
      @god_admin ||= gobierto_admin_admins(:natasha)
    end

    def site
      @site ||= sites(:madrid)
    end

    def site_group
      @site_group ||= gobierto_admin_admin_groups(:madrid_group)
    end
    alias regular_admin_normal_group site_group

    def regular_admin_system_group
      @regular_admin_system_group ||= gobierto_admin_admin_groups(:political_agendas_permissions_group)
    end

    def test_regular_admin_update
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(regular_admin_on_santander)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"

          within "#sites_permissions" do
            uncheck "santander.gobierto.test"
            check "madrid.gobierto.test"
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

          within "#sites_permissions" do
            assert has_no_checked_field?("santander.gobierto.test")
            assert has_checked_field?("madrid.gobierto.test")
          end

          within ".admin-authorization-level-radio-buttons" do
            assert has_checked_field?("Regular")
          end
        end
      end
    end

    def test_regular_admin_update_admin_groups
      with(site: site, admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin_on_santander)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"

          find("label[for='admin_admin_group_ids_#{site_group.id}']").click
          find("label[for='admin_authorization_level_regular']", visible: false).execute_script("this.click()")

          click_button "Update"
        end

        assert has_message?("Admin was successfully updated")

        assert find("#admin_admin_group_ids_#{site_group.id}", visible: false).checked?
        within "form.edit_admin" do
          assert has_field?("admin_email", with: "wadus@gobierto.dev")
          assert has_field?("admin_name", with: "Admin Name")
        end
      end
    end

    def test_regular_admin_update_does_not_include_system_groups
      with(site: site, admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        within "#admin_groups" do
          assert has_no_content? regular_admin_system_group.name
          assert has_content? regular_admin_normal_group.name
          find("label[for='admin_admin_group_ids_#{regular_admin_normal_group.id}']").click
        end

        click_button "Update"

        assert has_message?("Admin was successfully updated")
        assert_includes regular_admin.admin_groups, regular_admin_system_group
        refute_includes regular_admin.admin_groups, regular_admin_normal_group
      end
    end

    def test_regular_admin_deassign_admin_groups
      with(site: site, admin: manager_admin, js: true) do
        visit edit_admin_admin_path(regular_admin)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"

          find("label[for='admin_admin_group_ids_#{site_group.id}']").click
          find("label[for='admin_authorization_level_regular']", visible: false).execute_script("this.click()")

          click_button "Update"
        end

        assert has_message?("Admin was successfully updated")

        refute find("#admin_admin_group_ids_#{site_group.id}", visible: false).checked?
        within "form.edit_admin" do
          assert has_field?("admin_email", with: "wadus@gobierto.dev")
          assert has_field?("admin_name", with: "Admin Name")
        end
      end
    end

    def test_manager_admin_update
      with_signed_in_admin(god_admin) do
        visit edit_admin_admin_path(manager_admin)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_password", with: "wadus"
          fill_in "admin_password_confirmation", with: "wadus"

          assert has_no_selector?("#sites_permissions")

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          find("label[for='admin_permitted_sites_#{site.id}']", visible: false).click

          click_button "Update"
        end

        assert has_message?("Admin was successfully updated")

        within "form.edit_admin" do
          assert has_field?("admin_name", with: "Admin Name")
          assert has_field?("admin_email", with: manager_admin.email)

          within ".admin-authorization-level-radio-buttons" do
            assert has_checked_field?("Regular")
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

          assert has_no_selector?("#sites_permissions")
          assert has_no_selector?(".admin-authorization-level-radio-buttons")

          assert has_button?("Update", disabled: true)
        end
      end
    end

    def test_admin_update_with_not_matching_passwords
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(regular_admin)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"
          fill_in "admin_password", with: "wadus"
          fill_in "admin_password_confirmation", with: "foo"

          within "#sites_permissions" do
            check "madrid.gobierto.test"
          end

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          click_button "Update"
        end

        assert has_alert?("Password confirmation doesn't match Password")
      end
    end

    def test_admin_update_with_no_password_confirmation
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(regular_admin)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"
          fill_in "admin_password", with: "wadus"

          within "#sites_permissions" do
            check "madrid.gobierto.test"
          end

          within ".admin-authorization-level-radio-buttons" do
            choose "Regular"
          end

          click_button "Update"
        end

        assert has_alert?("Password confirmation doesn't match Password")
      end
    end
  end
end
