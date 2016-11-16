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

  def test_valid
    assert user.valid?
  end
end
