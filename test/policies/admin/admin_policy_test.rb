require 'test_helper'

class Admin::AdminPolicyTest < ActiveSupport::TestCase
  def user
    @user ||= admins(:tony)
  end

  def regular_admin
    @regular_admin ||= admins(:tony)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def god_admin
    @god_admin ||= admins(:natasha)
  end

  def test_manage_permissions?
    assert Admin::AdminPolicy.new(user, regular_admin).manage_permissions?
    assert Admin::AdminPolicy.new(user, manager_admin).manage_permissions?
    refute Admin::AdminPolicy.new(user, god_admin).manage_permissions?
  end

  def test_manage_sites?
    assert Admin::AdminPolicy.new(user, regular_admin).manage_sites?
    refute Admin::AdminPolicy.new(user, manager_admin).manage_sites?
    refute Admin::AdminPolicy.new(user, god_admin).manage_sites?
  end

  def test_manage_authorization_levels?
    assert Admin::AdminPolicy.new(user, regular_admin).manage_authorization_levels?
    assert Admin::AdminPolicy.new(user, manager_admin).manage_authorization_levels?
    refute Admin::AdminPolicy.new(user, god_admin).manage_authorization_levels?
  end
end
