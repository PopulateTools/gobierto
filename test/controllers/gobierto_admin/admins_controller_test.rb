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
  end
end
