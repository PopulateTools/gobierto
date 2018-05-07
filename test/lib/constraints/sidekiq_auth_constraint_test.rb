# frozen_string_literal: true

require "test_helper"

class SidekiqAuthConstraintTest < ActiveSupport::TestCase

  def regular_admin
    @regular_admin ||= gobierto_admin_admins(:tony)
  end

  def god_admin
    @god_admin ||= gobierto_admin_admins(:natasha)
  end

  def anonnymous_request
    request = mock
    request.stubs(:session).returns({})
    request
  end

  def regular_admin_request
    request = mock
    request.stubs(:session).returns(admin_id: regular_admin.id)
    request
  end

  def god_admin_request
    request = mock
    request.stubs(:session).returns(admin_id: god_admin.id)
    request
  end

  def test_god_admin?
    refute SidekiqAuthConstraint.god_admin?(anonnymous_request)
    refute SidekiqAuthConstraint.god_admin?(regular_admin_request)
    assert SidekiqAuthConstraint.god_admin?(god_admin_request)
  end

end
