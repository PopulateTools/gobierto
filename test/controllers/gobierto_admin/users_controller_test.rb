# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UsersControllerTest < GobiertoControllerTest
    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:dennis)
    end

    def setup
      super
      @notification_service_spy = Spy.on(Publishers::UserActivity, :broadcast_event)
      sign_in_admin(admin)
    end

    attr_reader :notification_service_spy

    def first_call_arguments
      notification_service_spy.calls.first.args
    end

    def valid_user_params
      {
        user: {
          name: user.name,
          email: user.email
        }
      }
    end

    def test_edit
      get edit_admin_user_url(user)
      assert_response :success
    end

    def test_update
      patch admin_user_url(user), params: valid_user_params
      assert_redirected_to edit_admin_user_path(user)
    end

    def test_update_broadcasts_event
      patch admin_user_url(user), params: valid_user_params
      assert_redirected_to edit_admin_user_path(user)

      assert notification_service_spy.has_been_called?
      event_name, event_payload = first_call_arguments
      assert_equal "user_updated", event_name
      assert_includes event_payload, :ip
      assert_equal event_payload[:author], admin
      assert_equal event_payload[:subject], user
      assert event_payload.include?(:changes)
    end
  end
end
