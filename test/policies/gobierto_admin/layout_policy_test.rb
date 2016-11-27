require "test_helper"

module GobiertoAdmin
  class LayoutPolicyTest < ActiveSupport::TestCase
    def regular_admin
      @regular_admin ||= admins(:tony)
    end

    def manager_admin
      @manager_admin ||= admins(:nick)
    end

    def test_can?
      assert LayoutPolicy.new(manager_admin, :manage_sites).can?
      refute LayoutPolicy.new(regular_admin, :manage_sites).can?
    end
  end
end
