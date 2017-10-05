# frozen_string_literal: true

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

    def madrid
      @madrid ||= sites(:madrid)
    end

    def santander
      @santander ||= sites(:santander)
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

        refute has_selector?("form.new_admin")
      end
    end

    def test_admin_create_and_admin_accept_email
      with_javascript do
        with_signed_in_admin(admin) do
          visit @path

          within "form.new_admin" do
            fill_in "admin_name", with: "Admin Name"
            fill_in "admin_email", with: "admin@email.dev"

            # grant permissions for Gobierto Development
            find("label[for='admin_permitted_modules_gobiertodevelopment']").click

            # set authorization level to 'Regular'
            find("label[for='admin_authorization_level_regular']", visible: false).click

            # grant permissions for madrid.gobierto.dev
            find("label[for='admin_permitted_sites_#{madrid.id}']").click

            click_button "Create"
          end

          assert has_message?("Admin was successfully created")

          assert has_content?("Admin Name")
          assert has_content?("admin@email.dev")

          click_link "Admin Name"

          # assert GobiertoDevelopment is checked
          assert find("#admin_permitted_modules_gobiertodevelopment", visible: false).checked?
          # refute GobiertoDevelopment is checked
          refute find("#admin_permitted_modules_gobiertobudgets", visible: false).checked?

          # assert Madrid is checked
          assert find("#admin_permitted_sites_#{madrid.id}", visible: false).checked?
          # refute Santander is checked
          refute find("#admin_permitted_sites_#{santander.id}", visible: false).checked?

          # assert admin is Regular
          assert find("#admin_authorization_level_regular", visible: false).checked?

          invite_email = ActionMailer::Base.deliveries.last
          assert_equal "admin@email.dev", invite_email.to[0]
        end
      end

      open_email("admin@email.dev")
      current_email.click_link current_email.first("a").text

      assert has_message?("Signed in successfully")

      assert has_content?("Edit your data")

      assert has_field?("admin_email", with: "admin@email.dev")
      fill_in :admin_password, with: "gobierto"
      fill_in :admin_password_confirmation, with: "gobierto"
      click_button "Update"

      assert has_message?("Data updated successfully")
    end

    def test_create_admin_with_sites_modules_and_people
      with_javascript do
        with_signed_in_admin(admin) do

          visit @path

          fill_in "admin_name", with: "Admin Name"
          fill_in "admin_email", with: "admin@email.dev"

          # set authorization level to 'Regular'
          find("label[for='admin_authorization_level_regular']", visible: false).click

          # grant permissions for madrid.gobierto.dev
          find("label[for='admin_permitted_sites_#{madrid.id}']").click

          # grant permissions for Gobierto People
          find("label[for='admin_permitted_modules_gobiertopeople']").click

          # grant permissions for Richard Rider
          find("label[for='admin_permitted_people_#{richard.id}']", visible: false).trigger(:click)

          click_button "Create"

          assert has_message?("Admin was successfully created")
        end
      end

      new_admin = ::GobiertoAdmin::Admin.last
      permissions = new_admin.permissions
      module_permission = permissions.find_by(resource_name: 'gobierto_people')
      person_permission = permissions.find_by(resource_name: 'person')

      # assert site permissions

      assert_equal [madrid], new_admin.sites

      # assert total permissions

      assert_equal 2, permissions.size

      # assert module permissions

      assert_equal 'site_module', module_permission.namespace
      assert_nil module_permission.resource_id
      assert_equal 'manage', module_permission.action_name

      # assert person permissions

      assert_equal 'gobierto_people', person_permission.namespace
      assert_equal richard.id, person_permission.resource_id
      assert_equal 'manage', person_permission.action_name
    end

  end
end
