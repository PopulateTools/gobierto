# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class Admin::SettingsControllerTest < GobiertoControllerTest
    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def setup
      super
      sign_in_admin(admin)
    end

    def teardown
      super
      sign_out_admin
    end

    def valid_settings_params(notification_settings = {})
      {
        admin: {
          name: admin.name,
          email: admin.email,
          notification_settings: notification_settings
        }
      }
    end

    def test_edit
      get edit_admin_admin_settings_url

      assert_response :success
      assert_includes response.body, "admin[notification_settings][gobierto_plans]"
    end

    def test_update_disabling_a_module
      patch admin_admin_settings_url, params: valid_settings_params("gobierto_plans" => "0")

      assert_redirected_to edit_admin_admin_settings_url
      assert_equal({ "gobierto_plans" => false }, admin.reload.notification_settings)
    end

    def test_update_enabling_a_module
      admin.update!(notification_settings: { "gobierto_plans" => false })

      patch admin_admin_settings_url, params: valid_settings_params("gobierto_plans" => "1")

      assert_redirected_to edit_admin_admin_settings_url
      assert_equal({ "gobierto_plans" => true }, admin.reload.notification_settings)
    end

    def test_update_ignores_unknown_notification_settings
      admin.update!(notification_settings: { "gobierto_plans" => false })

      patch admin_admin_settings_url, params: valid_settings_params("wadus_module" => "1")

      assert_redirected_to edit_admin_admin_settings_url
      assert_equal({ "gobierto_plans" => false }, admin.reload.notification_settings)
    end

    def test_update_ignores_notification_settings_with_an_unexpected_shape
      admin.update!(notification_settings: { "gobierto_plans" => false })

      patch admin_admin_settings_url, params: valid_settings_params("gobierto_plans" => ["1"])

      assert_redirected_to edit_admin_admin_settings_url
      assert_equal({ "gobierto_plans" => false }, admin.reload.notification_settings)
    end

    def test_update_without_notification_settings_keeps_them
      admin.update!(notification_settings: { "gobierto_plans" => false })

      patch admin_admin_settings_url, params: { admin: { name: "Tony Stark", email: admin.email } }

      assert_redirected_to edit_admin_admin_settings_url
      assert_equal({ "gobierto_plans" => false }, admin.reload.notification_settings)
    end
  end
end
