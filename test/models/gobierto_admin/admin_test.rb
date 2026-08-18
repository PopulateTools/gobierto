# frozen_string_literal: true

require "test_helper"
require "support/concerns/authentication/authenticable_test"
require "support/concerns/authentication/confirmable_test"
require "support/concerns/authentication/invitable_test"
require "support/concerns/authentication/recoverable_test"
require "support/concerns/session/trackable_test"

module GobiertoAdmin
  class AdminTest < ActiveSupport::TestCase
    include Authentication::AuthenticableTest
    include Authentication::InvitableTest
    include Authentication::RecoverableTest
    include Session::TrackableTest

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end
    alias user admin

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def god_admin
      @god_admin ||= gobierto_admin_admins(:natasha)
    end

    def invited_admin
      @invited_admin ||= gobierto_admin_admins(:steve)
    end
    alias invited_user invited_admin

    def recoverable_admin
      @recoverable_admin ||= gobierto_admin_admins(:tony)
    end
    alias recoverable_user recoverable_admin

    def not_recoverable_admin
      @not_recoverable_admin ||= gobierto_admin_admins(:nick)
    end
    alias not_recoverable_user not_recoverable_admin

    def test_preset_scope_when_god_admin_is_present
      assert_equal god_admin, Admin.preset
    end

    def test_preset_scope_when_god_admin_is_not_present
      Admin.god.delete_all

      preset_admin = Admin.preset

      expected_admin = Admin.new(
        email: "admin@gobierto.dev",
        name: "Gobierto Admin"
      )

      assert_equal expected_admin.email, preset_admin.email
      assert_equal expected_admin.name, preset_admin.name
    end

    def test_valid
      assert admin.valid?
    end

    # -- Initialization
    def test_god_flag_initialization_when_it_is_already_present
      admin.send :set_god_flag
      refute admin.god
    end

    def test_god_flag_initialization_when_it_is_not_already_present
      Admin.god.delete_all
      admin.send :set_god_flag
      assert admin.god
    end

    # -- Authorization levels
    def test_sites_for_regular_authorization_level
      assert_equal 2, admin.sites.count
    end

    def test_sites_bypass_for_manager_authorization_level
      assert_equal Site.count, manager_admin.sites.count
    end

    def test_sites_bypass_for_god_admin
      assert_equal Site.count, god_admin.sites.count
    end

    def test_managing_user?
      assert god_admin.managing_user?
      assert manager_admin.managing_user?
      refute admin.managing_user?
    end

    def module_allowed?(_module_namespace)
      refute admin.module_allowed?("GobiertoCms")
    end

    def test_can_manage_admins
      assert god_admin.can_manage_admins?
      assert manager_admin.can_manage_admins?
      refute admin.can_manage_admins?

      grant_admins_permission_on_madrid

      assert admin.can_manage_admins?
    end

    def grant_admins_permission_on_madrid
      GobiertoAdmin::GroupPermission.create!(
        admin_group: gobierto_admin_admin_groups(:madrid_group),
        namespace: "site_options",
        resource_type: "admins",
        action_name: "manage"
      )
    end

    # tony administers madrid and santander, but the permission is granted through
    # a group that belongs to madrid.
    def test_can_manage_admins_in_a_given_site
      refute admin.can_manage_admins?(sites(:madrid))

      grant_admins_permission_on_madrid

      assert admin.can_manage_admins?(sites(:madrid))
      refute admin.can_manage_admins?(sites(:santander))
    end

    def test_can_manage_admins_in_a_given_site_for_managing_users
      assert manager_admin.can_manage_admins?(sites(:santander))
      assert god_admin.can_manage_admins?(sites(:santander))
    end

    def test_sites_with_admins_permission
      assert_empty admin.sites_with_admins_permission

      grant_admins_permission_on_madrid

      assert_equal [sites(:madrid)], admin.sites_with_admins_permission.to_a
    end

    def test_sites_with_admins_permission_for_managing_users
      assert_equal Site.count, manager_admin.sites_with_admins_permission.count
      assert_equal Site.count, god_admin.sites_with_admins_permission.count
    end

    def test_regular_or_disabled_on_site_scope
      madrid = sites(:madrid)
      podrick = gobierto_admin_admins(:podrick)
      GobiertoAdmin::AdminSite.create!(admin: podrick, site: madrid)

      madrid_admins = Admin.regular_or_disabled_on_site(madrid)

      assert_includes madrid_admins, gobierto_admin_admins(:tony)
      assert_includes madrid_admins, gobierto_admin_admins(:steve)
      assert_includes madrid_admins, podrick
      refute_includes madrid_admins, manager_admin
      refute_includes madrid_admins, god_admin
    end

    def test_send_notifications_without_stored_settings
      assert_empty admin.notification_settings
      assert admin.send_notifications?("GobiertoPlans")
    end

    def test_send_notifications_for_a_disabled_module
      admin.update!(notification_settings: { "gobierto_plans" => false })

      refute admin.send_notifications?("GobiertoPlans")
    end

    def test_send_notifications_for_an_enabled_module
      admin.update!(notification_settings: { "gobierto_plans" => true })

      assert admin.send_notifications?("GobiertoPlans")
    end

    def test_send_notifications_for_an_unsettled_module
      admin.update!(notification_settings: { "gobierto_plans" => false })

      assert admin.send_notifications?("GobiertoBudgets")
    end

    def test_notifiable_modules
      assert_equal ["gobierto_plans"], admin.notifiable_modules
    end

    def test_notifiable_modules_without_sites
      assert_empty gobierto_admin_admins(:podrick).notifiable_modules
    end
  end
end
