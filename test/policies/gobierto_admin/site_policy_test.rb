# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SitePolicyTest < ActiveSupport::TestCase

    def regular_admin_with_customize_permissions
      @regular_admin_with_customize_permissions ||= gobierto_admin_admins(:tony)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:steve)
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_list
      assert SitePolicy.new(manager_admin, site).list?
      refute SitePolicy.new(regular_admin, site).list?
      refute SitePolicy.new(regular_admin_with_customize_permissions, site).list?
    end

    def test_create?
      assert SitePolicy.new(manager_admin, site).create?
      refute SitePolicy.new(regular_admin, site).create?
      refute SitePolicy.new(regular_admin_with_customize_permissions, site).create?
    end

    def test_update?
      assert SitePolicy.new(manager_admin, site).update?
      refute SitePolicy.new(regular_admin, site).update?
      assert SitePolicy.new(regular_admin_with_customize_permissions, site).update?
    end

    def test_delete?
      assert SitePolicy.new(manager_admin, site).delete?
      refute SitePolicy.new(regular_admin, site).delete?
      refute SitePolicy.new(regular_admin_with_customize_permissions, site).delete?
    end
  end
end
