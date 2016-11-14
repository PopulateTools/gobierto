require "test_helper"

class AdminTest < ActiveSupport::TestCase
  def admin
    @admin ||= admins(:tony)
  end

  def unconfirmed_admin
    @unconfirmed_admin ||= admins(:steve)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def god_admin
    @god_admin ||= admins(:natasha)
  end

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

  # -- Authentication::Authenticable
  def test_password_authentication
    assert admin.authenticate("gobierto")
  end

  # -- Authentication::Confirmable
  def test_confirmed_scope
    subject = Admin.confirmed

    assert_includes subject, admin
    refute_includes subject, unconfirmed_admin
  end

  def test_confirmed?
    assert admin.confirmed?
    refute unconfirmed_admin.confirmed?
  end

  def test_confirm!
    refute unconfirmed_admin.confirmed?

    unconfirmed_admin.confirm!
    assert unconfirmed_admin.confirmed?
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

  # -- Session
  def test_update_session_data
    remote_ip = IPAddr.new("0.0.0.0")
    timestamp = Time.zone.now

    assert_nil admin.last_sign_in_ip
    assert_nil admin.last_sign_in_at

    admin.update_session_data(remote_ip, timestamp)
    assert_equal remote_ip, admin.last_sign_in_ip
    assert_equal timestamp, admin.last_sign_in_at
  end
end
