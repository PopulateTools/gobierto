require "test_helper"
require "support/concerns/authentication/authenticable_test"
require "support/concerns/authentication/confirmable_test"
require "support/concerns/authentication/invitable_test"
require "support/concerns/authentication/recoverable_test"
require "support/concerns/session/trackable_test"

class AdminTest < ActiveSupport::TestCase
  include Authentication::AuthenticableTest
  include Authentication::ConfirmableTest
  include Authentication::InvitableTest
  include Authentication::RecoverableTest
  include Session::TrackableTest

  def admin
    @admin ||= admins(:tony)
  end
  alias user admin

  def unconfirmed_admin
    @unconfirmed_admin ||= admins(:steve)
  end
  alias unconfirmed_user unconfirmed_admin

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def god_admin
    @god_admin ||= admins(:natasha)
  end

  def invited_admin
    @invited_admin ||= admins(:steve)
  end
  alias invited_user invited_admin

  def recoverable_admin
    @recoverable_admin ||= admins(:steve)
  end
  alias recoverable_user recoverable_admin

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
    assert_send [admin, :set_god_flag]
    refute admin.god
  end

  def test_god_flag_initialization_when_it_is_not_already_present
    Admin.god.delete_all
    assert_send [admin, :set_god_flag]
    assert admin.god
  end

  # -- Authorization levels
  def test_sites_for_regular_authorization_level
    assert_equal 1, admin.sites.count
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
end
