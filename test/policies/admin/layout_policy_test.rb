require "test_helper"

class Admin::LayoutPolicyTest < ActiveSupport::TestCase
  def regular_admin
    @regular_admin ||= admins(:tony)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def test_can?
    assert Admin::LayoutPolicy.new(manager_admin, :manage_sites).can?
    refute Admin::LayoutPolicy.new(regular_admin, :manage_sites).can?
  end
end
