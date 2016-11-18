require "test_helper"
require "support/concerns/authentication/authenticable_test"
require "support/concerns/authentication/confirmable_test"
require "support/concerns/authentication/recoverable_test"
require "support/concerns/session/trackable_test"

class UserTest < ActiveSupport::TestCase
  include Authentication::AuthenticableTest
  include Authentication::ConfirmableTest
  include Authentication::RecoverableTest
  include Session::TrackableTest

  def user
    @user ||= users(:dennis)
  end

  def unconfirmed_user
    @unconfirmed_user ||= users(:reed)
  end

  def recoverable_user
    @recoverable_user ||= users(:reed)
  end

  def madrid_site
    @madrid_site ||= sites(:madrid)
  end

  def madrid_user
    @madrid_user ||= users(:dennis)
  end

  def santander_user
    @santander_user ||= users(:susan)
  end

  def test_by_user_site_scope
    subject = User.by_source_site(madrid_site)

    assert_includes subject, madrid_user
    refute_includes subject, santander_user
  end

  def test_valid
    assert user.valid?
  end
end
