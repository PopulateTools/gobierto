require 'test_helper'

module GobiertoAdmin
  class AdminPolicyTest < ActiveSupport::TestCase
    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def god_admin
      @god_admin ||= gobierto_admin_admins(:natasha)
    end

    def test_update?
      assert AdminPolicy.new(god_admin, god_admin).update?
      assert AdminPolicy.new(god_admin, manager_admin).update?
      assert AdminPolicy.new(god_admin, regular_admin).update?

      refute AdminPolicy.new(manager_admin, god_admin).update?
      assert AdminPolicy.new(manager_admin, manager_admin).update?
      assert AdminPolicy.new(manager_admin, regular_admin).update?

      refute AdminPolicy.new(regular_admin, god_admin).update?
      refute AdminPolicy.new(regular_admin, manager_admin).update?
      refute AdminPolicy.new(regular_admin, regular_admin).update?
    end

    def test_manage_permissions?
      assert AdminPolicy.new(god_admin, god_admin).manage_permissions?
      assert AdminPolicy.new(god_admin, manager_admin).manage_permissions?
      assert AdminPolicy.new(god_admin, regular_admin).manage_permissions?

      refute AdminPolicy.new(manager_admin, god_admin).manage_permissions?
      assert AdminPolicy.new(manager_admin, manager_admin).manage_permissions?
      assert AdminPolicy.new(manager_admin, regular_admin).manage_permissions?

      refute AdminPolicy.new(regular_admin, god_admin).manage_permissions?
      refute AdminPolicy.new(regular_admin, manager_admin).manage_permissions?
      refute AdminPolicy.new(regular_admin, regular_admin).manage_permissions?
    end

    def test_manage_sites?
      refute AdminPolicy.new(god_admin, god_admin).manage_sites?
      refute AdminPolicy.new(god_admin, manager_admin).manage_sites?
      assert AdminPolicy.new(god_admin, regular_admin).manage_sites?

      refute AdminPolicy.new(manager_admin, god_admin).manage_sites?
      refute AdminPolicy.new(manager_admin, manager_admin).manage_sites?
      assert AdminPolicy.new(manager_admin, regular_admin).manage_sites?

      refute AdminPolicy.new(regular_admin, god_admin).manage_sites?
      refute AdminPolicy.new(regular_admin, manager_admin).manage_sites?
      refute AdminPolicy.new(regular_admin, regular_admin).manage_sites?
    end

    def manage_authorization_levels?
      assert AdminPolicy.new(god_admin, god_admin).manage_authorization_levels?
      assert AdminPolicy.new(god_admin, manager_admin).manage_authorization_levels?
      assert AdminPolicy.new(god_admin, regular_admin).manage_authorization_levels?

      refute AdminPolicy.new(manager_admin, god_admin).manage_authorization_levels?
      assert AdminPolicy.new(manager_admin, manager_admin).manage_authorization_levels?
      assert AdminPolicy.new(manager_admin, regular_admin).manage_authorization_levels?

      refute AdminPolicy.new(regular_admin, god_admin).manage_authorization_levels?
      refute AdminPolicy.new(regular_admin, manager_admin).manage_authorization_levels?
      refute AdminPolicy.new(regular_admin, regular_admin).manage_authorization_levels?
    end
  end
end
