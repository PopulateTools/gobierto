# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminGroupUpdateTest < ActionDispatch::IntegrationTest

    def tony
      @tony ||= gobierto_admin_admins(:tony)
    end
    alias_method :regular_admin, :tony

    def steve
      @steve ||= gobierto_admin_admins(:steve)
    end
    alias_method :regular_admin_on_santander, :steve

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def god_admin
      @god_admin ||= gobierto_admin_admins(:natasha)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_regular_admin_update
      with_signed_in_admin(manager_admin) do
        visit edit_admin_admin_path(regular_admin_on_santander)

        within "form.edit_admin" do
          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "wadus@gobierto.dev"

          within ".site-check-boxes" do
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

          within ".site-check-boxes" do
            assert has_no_checked_field?("santander.gobierto.test")
            assert has_checked_field?("madrid.gobierto.test")
          end

          within ".admin-authorization-level-radio-buttons" do
            assert has_checked_field?("Regular")
          end
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

          assert has_no_selector?(".site-check-boxes")

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

          assert has_no_selector?(".site-check-boxes")
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

          within ".site-check-boxes" do
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

          within ".site-check-boxes" do
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
