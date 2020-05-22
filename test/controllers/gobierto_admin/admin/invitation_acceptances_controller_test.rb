# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class Admin::InvitationAcceptancesControllerTest < GobiertoControllerTest
    def invited_admin
      @invited_admin ||= gobierto_admin_admins(:steve)
    end

    def setup
      super
      @notification_service_spy = Spy.on(Publishers::AdminActivity, :broadcast_event)
    end

    attr_reader :notification_service_spy

    def first_call_arguments
      notification_service_spy.calls.first.args
    end

    def invitation_token
      invited_admin.invitation_token
    end

    def valid_invitation_params
      {
        invitation_token: invitation_token
      }
    end

    def test_show
      get admin_admin_invitation_acceptances_url(valid_invitation_params)
      assert_response :redirect
    end

    def test_show_broadcast_event
      get admin_admin_invitation_acceptances_url(valid_invitation_params)
      assert_response :redirect

      assert notification_service_spy.has_been_called?
      event_name, event_payload = first_call_arguments
      assert_equal "invitation_accepted", event_name
      assert_includes event_payload, :ip
      assert_equal event_payload[:author], invited_admin
      assert_equal event_payload[:subject], invited_admin
      refute event_payload.include?(:changes)
    end
  end
end
