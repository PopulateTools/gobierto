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

    def madrid_group
      @madrid_group ||= gobierto_admin_admin_groups(:madrid_group)
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

        assert has_no_selector?("form.new_admin")
      end
    end

    def test_admin_create_and_admin_accept_email
      with_javascript do
        with_current_site(madrid) do
          with_signed_in_admin(admin) do
            visit @path

            within "form.new_admin" do
              fill_in "admin_name", with: "Admin Name"
              fill_in "admin_email", with: "admin@email.dev"

              # set authorization level to 'Regular'
              find("label[for='admin_authorization_level_regular']", visible: false).click

              # grant permissions for madrid.gobierto.test
              find("label[for='admin_permitted_sites_#{madrid.id}']").click

              # grant permissions for madrid group
              find("label[for='admin_admin_group_ids_#{madrid_group.id}']").click

              click_button "Create"
            end

            assert has_message?("Admin was successfully created")

            assert has_content?("Admin Name")
            assert has_content?("admin@email.dev")

            click_link "Admin Name"

            # assert Madrid is checked
            assert find("#admin_permitted_sites_#{madrid.id}", visible: false).checked?
            # refute Santander is checked
            refute find("#admin_permitted_sites_#{santander.id}", visible: false).checked?

            # assert Madrid group is checked
            assert find("#admin_admin_group_ids_#{madrid_group.id}", visible: false).checked?

            # assert admin is Regular
            assert find("#admin_authorization_level_regular", visible: false).checked?

            invite_email = ActionMailer::Base.deliveries.last
            assert_equal "admin@email.dev", invite_email.to[0]
          end
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

    def test_create_regular_admin_with_custom_permissions
      with_javascript do
        with_current_site(madrid) do
          with_signed_in_admin(admin) do
            visit @path

            fill_in "admin_name", with: "Admin Name"
            fill_in "admin_email", with: "admin@email.dev"

            # set authorization level to 'Regular'
            find("label[for='admin_authorization_level_regular']", visible: false).click

            # grant permissions for madrid.gobierto.test
            find("label[for='admin_permitted_sites_#{madrid.id}']").click

            # grant permissions for madrid group
            find("label[for='admin_admin_group_ids_#{madrid_group.id}']").click

            click_button "Create"

            assert has_message?("Admin was successfully created")
          end
        end
      end

      new_admin = ::GobiertoAdmin::Admin.last

      assert_equal [madrid], new_admin.sites
      assert_equal [madrid_group], new_admin.admin_groups
    end
  end
end
