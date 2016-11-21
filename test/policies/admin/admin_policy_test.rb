require 'test_helper'

class Admin::AdminPolicyTest < ActiveSupport::TestCase
  def regular_admin
    @regular_admin ||= admins(:tony)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def god_admin
    @god_admin ||= admins(:natasha)
  end

  def test_update?
    assert Admin::AdminPolicy.new(god_admin, god_admin).update?
    assert Admin::AdminPolicy.new(god_admin, manager_admin).update?
    assert Admin::AdminPolicy.new(god_admin, regular_admin).update?

    refute Admin::AdminPolicy.new(manager_admin, god_admin).update?
    assert Admin::AdminPolicy.new(manager_admin, manager_admin).update?
    assert Admin::AdminPolicy.new(manager_admin, regular_admin).update?

    refute Admin::AdminPolicy.new(regular_admin, god_admin).update?
    refute Admin::AdminPolicy.new(regular_admin, manager_admin).update?
    refute Admin::AdminPolicy.new(regular_admin, regular_admin).update?
  end

  def test_manage_permissions?
    assert Admin::AdminPolicy.new(god_admin, god_admin).manage_permissions?
    assert Admin::AdminPolicy.new(god_admin, manager_admin).manage_permissions?
    assert Admin::AdminPolicy.new(god_admin, regular_admin).manage_permissions?

    refute Admin::AdminPolicy.new(manager_admin, god_admin).manage_permissions?
    assert Admin::AdminPolicy.new(manager_admin, manager_admin).manage_permissions?
    assert Admin::AdminPolicy.new(manager_admin, regular_admin).manage_permissions?

    refute Admin::AdminPolicy.new(regular_admin, god_admin).manage_permissions?
    refute Admin::AdminPolicy.new(regular_admin, manager_admin).manage_permissions?
    refute Admin::AdminPolicy.new(regular_admin, regular_admin).manage_permissions?
  end

  def test_manage_sites?
    refute Admin::AdminPolicy.new(god_admin, god_admin).manage_sites?
    refute Admin::AdminPolicy.new(god_admin, manager_admin).manage_sites?
    assert Admin::AdminPolicy.new(god_admin, regular_admin).manage_sites?

    refute Admin::AdminPolicy.new(manager_admin, god_admin).manage_sites?
    refute Admin::AdminPolicy.new(manager_admin, manager_admin).manage_sites?
    assert Admin::AdminPolicy.new(manager_admin, regular_admin).manage_sites?

    refute Admin::AdminPolicy.new(regular_admin, god_admin).manage_sites?
    refute Admin::AdminPolicy.new(regular_admin, manager_admin).manage_sites?
    refute Admin::AdminPolicy.new(regular_admin, regular_admin).manage_sites?
  end

  def manage_authorization_levels?
    assert Admin::AdminPolicy.new(god_admin, god_admin).manage_authorization_levels?
    assert Admin::AdminPolicy.new(god_admin, manager_admin).manage_authorization_levels?
    assert Admin::AdminPolicy.new(god_admin, regular_admin).manage_authorization_levels?

    refute Admin::AdminPolicy.new(manager_admin, god_admin).manage_authorization_levels?
    assert Admin::AdminPolicy.new(manager_admin, manager_admin).manage_authorization_levels?
    assert Admin::AdminPolicy.new(manager_admin, regular_admin).manage_authorization_levels?

    refute Admin::AdminPolicy.new(regular_admin, god_admin).manage_authorization_levels?
    refute Admin::AdminPolicy.new(regular_admin, manager_admin).manage_authorization_levels?
    refute Admin::AdminPolicy.new(regular_admin, regular_admin).manage_authorization_levels?
  end
end
