# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class Admin::InvitationsControllerTest < GobiertoControllerTest
    def site
      @site ||= sites(:madrid)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
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

    def valid_invitation_params
      {
        admin_invitation: {
          emails: "email1@example.com,email2@example.com",
          site_ids: ["", site.id]
        }
      }
    end

    def test_create
      post admin_admin_invitations_url, params: valid_invitation_params
      assert_response :success
    end

    def test_create_broadcast_event
      post admin_admin_invitations_url, params: valid_invitation_params
      assert_response :success

      assert notification_service_spy.has_been_called?
      event_name, event_payload = first_call_arguments
      assert_equal "invitation_created", event_name
      assert_includes event_payload, :ip
      assert_equal event_payload[:author], admin
      assert_nil event_payload[:subject]
      refute event_payload.include?(:changes)
    end
  end
end
