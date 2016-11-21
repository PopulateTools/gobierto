require "test_helper"

class Admin::SitePolicyTest < ActiveSupport::TestCase
  def regular_admin
    @regular_admin ||= admins(:tony)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_view?
    assert Admin::SitePolicy.new(manager_admin, site).view?
    refute Admin::SitePolicy.new(regular_admin, site).view?
  end

  def test_create?
    assert Admin::SitePolicy.new(manager_admin, site).create?
    refute Admin::SitePolicy.new(regular_admin, site).create?
  end

  def test_update?
    assert Admin::SitePolicy.new(manager_admin, site).update?
    refute Admin::SitePolicy.new(regular_admin, site).update?
  end

  def test_delete?
    assert Admin::SitePolicy.new(manager_admin, site).delete?
    refute Admin::SitePolicy.new(regular_admin, site).delete?
  end
end
