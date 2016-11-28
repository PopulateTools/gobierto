require "test_helper"

module GobiertoAdmin
  class SitePolicyTest < ActiveSupport::TestCase
    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_view?
      assert SitePolicy.new(manager_admin, site).view?
      refute SitePolicy.new(regular_admin, site).view?
    end

    def test_create?
      assert SitePolicy.new(manager_admin, site).create?
      refute SitePolicy.new(regular_admin, site).create?
    end

    def test_update?
      assert SitePolicy.new(manager_admin, site).update?
      refute SitePolicy.new(regular_admin, site).update?
    end

    def test_delete?
      assert SitePolicy.new(manager_admin, site).delete?
      refute SitePolicy.new(regular_admin, site).delete?
    end
  end
end
