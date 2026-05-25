# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminsControllerTest < GobiertoControllerTest
    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def santander
      @santander ||= sites(:santander)
    end

    def steve
      @steve ||= gobierto_admin_admins(:steve)
    end

    def tony
      @tony ||= gobierto_admin_admins(:tony)
    end

    def madrid_group
      @madrid_group ||= gobierto_admin_admin_groups(:madrid_group)
    end

    def grant_admins_permission_to(admin_group)
      GobiertoAdmin::GroupPermission.create!(
        admin_group: admin_group,
        namespace: "site_options",
        resource_type: "admins",
        action_name: "manage"
      )
    end

    def setup
      super
      @notification_service_spy = Spy.on(Publishers::AdminActivity, :broadcast_event)
      sign_in_admin(admin)
    end

    attr_reader :notification_service_spy

    def first_call_arguments
      notification_service_spy.calls.first.args
    end

    def teardown
      super
      sign_out_admin
    end

    def valid_admin_params
      {
        admin: {
          name: admin.name,
          email: admin.email,
          password: "wadus",
          site_modules: %w(GobiertoPeople),
          site_ids: ["", site.id]
        }
      }
    end

    def valid_created_admin_params
      {
        admin: {
          name: "New admin name",
          email: "newadmin@example.com",
          password: "wadus",
          password_confirmation: "wadus",
          site_modules: %w(GobiertoPeople),
          site_ids: ["", site.id]
        }
      }
    end

    def test_create_admin_broadcasts_event
      post admin_admins_url, params: valid_created_admin_params
      assert_response :redirect

      assert notification_service_spy.has_been_called?
      event_name, event_payload = first_call_arguments
      assert_equal "admin_created", event_name
      assert_includes event_payload, :ip
      assert_equal event_payload[:author], admin
      assert_equal event_payload[:subject], GobiertoAdmin::Admin.last
      refute event_payload.include?(:changes)
    end

    def test_edit
      get edit_admin_admin_url(admin)
      assert_response :success
    end

    def test_update
      patch admin_admin_url(admin), params: valid_admin_params
      assert_redirected_to edit_admin_admin_path(admin)
    end

    def test_update_admin_broadcasts_event
      patch admin_admin_url(admin), params: valid_admin_params
      assert_redirected_to edit_admin_admin_path(admin)

      assert notification_service_spy.has_been_called?
      event_name, event_payload = first_call_arguments
      assert_equal "admin_updated", event_name
      assert_includes event_payload, :ip
      assert_equal event_payload[:author], admin
      assert_equal event_payload[:subject], admin
      assert event_payload.include?(:changes)
    end

    def test_index_redirects_regular_admin_without_admins_permission
      sign_out_admin
      sign_in_admin(tony)

      get admin_admins_url
      assert_redirected_to admin_users_path
    end

    def test_index_for_regular_admin_with_admins_permission_excludes_managing_users
      grant_admins_permission_to(madrid_group)
      GobiertoAdmin::GroupsAdmin.create!(admin: steve, admin_group: madrid_group)
      sign_out_admin
      sign_in_admin(steve)

      get admin_admins_url
      assert_response :success

      assert_includes response.body, steve.email
      assert_includes response.body, tony.email
      refute_includes response.body, admin.email # manager
      refute_includes response.body, gobierto_admin_admins(:natasha).email # god
    end

    def test_create_restricts_permitted_sites_to_current_admin_sites
      grant_admins_permission_to(madrid_group)
      GobiertoAdmin::GroupsAdmin.create!(admin: steve, admin_group: madrid_group)
      sign_out_admin
      sign_in_admin(steve)

      params = {
        admin: {
          name: "Bruce Banner",
          email: "bruce@gobierto.dev",
          authorization_level: "regular",
          permitted_sites: ["", site.id.to_s, santander.id.to_s]
        }
      }

      assert_difference "GobiertoAdmin::Admin.count", 1 do
        post admin_admins_url, params: params
      end
      assert_redirected_to admin_admins_path

      created = GobiertoAdmin::Admin.find_by(email: "bruce@gobierto.dev")
      assert_equal [site], created.sites
    end

    def test_update_restricts_permitted_sites_to_current_admin_sites
      grant_admins_permission_to(madrid_group)
      GobiertoAdmin::GroupsAdmin.create!(admin: steve, admin_group: madrid_group)
      sign_out_admin
      sign_in_admin(steve)

      target = GobiertoAdmin::Admin.create!(
        name: "Bruce Banner",
        email: "bruce@gobierto.dev",
        password: "gobierto",
        authorization_level: "regular"
      )
      GobiertoAdmin::AdminSite.create!(admin: target, site: site)

      patch admin_admin_url(target), params: {
        admin: {
          name: target.name,
          email: target.email,
          authorization_level: "regular",
          permitted_sites: ["", site.id.to_s, santander.id.to_s]
        }
      }
      assert_redirected_to edit_admin_admin_path(target)

      assert_equal [site], target.reload.sites
    end

    def test_form_hides_sites_selector_for_single_site_regular_admin
      grant_admins_permission_to(madrid_group)
      GobiertoAdmin::GroupsAdmin.create!(admin: steve, admin_group: madrid_group)
      sign_out_admin
      sign_in_admin(steve)

      get new_admin_admin_url
      assert_response :success

      refute_includes response.body, 'id="sites_permissions"'
      assert_match %r{<input[^>]*type="hidden"[^>]*name="admin\[permitted_sites\]\[\]"[^>]*value="#{site.id}"}, response.body
    end

    def test_form_shows_groups_for_single_site_regular_admin
      grant_admins_permission_to(madrid_group)
      GobiertoAdmin::GroupsAdmin.create!(admin: steve, admin_group: madrid_group)
      sign_out_admin
      sign_in_admin(steve)

      get new_admin_admin_url
      assert_response :success

      assert_includes response.body, 'id="admin_groups"'
      assert_match %r{<div[^>]*id="admin_groups"[^>]*style="\s*"}, response.body
      assert_includes response.body, madrid_group.name
    end

    def test_form_shows_sites_selector_for_multi_site_regular_admin
      grant_admins_permission_to(madrid_group)
      sign_out_admin
      sign_in_admin(tony)

      get new_admin_admin_url
      assert_response :success

      assert_includes response.body, 'id="sites_permissions"'
    end
  end
end
