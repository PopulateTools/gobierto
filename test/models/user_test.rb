# frozen_string_literal: true

require "test_helper"
require "support/concerns/authentication/authenticable_test"
require "support/concerns/authentication/confirmable_test"
require "support/concerns/authentication/recoverable_test"
require "support/concerns/session/trackable_test"
require "support/concerns/user/subscriber_test"

class UserTest < ActiveSupport::TestCase
  include Authentication::AuthenticableTest
  include Authentication::ConfirmableTest
  include Authentication::RecoverableTest
  include Session::TrackableTest
  include User::SubscriberTest

  def user
    @user ||= users(:dennis)
  end
  alias subscribed_user user

  def unconfirmed_user
    @unconfirmed_user ||= users(:reed)
  end

  def recoverable_user
    @recoverable_user ||= users(:dennis)
  end

  def not_recoverable_user
    @not_recoverable_user ||= users(:susan)
  end

  def madrid_site
    @madrid_site ||= sites(:madrid)
  end

  def madrid_user
    @madrid_user ||= users(:dennis)
  end

  def other_madrid_user
    @other_madrid_user ||= users(:janet)
  end

  def santander_user
    @santander_user ||= users(:susan)
  end

  def test_by_user_site_scope
    subject = User.by_site(madrid_site)

    assert_includes subject, madrid_user
    refute_includes subject, santander_user
  end

  def test_email_unique_scoped_to_site
    santander_user.email = madrid_user.email
    other_madrid_user.email = madrid_user.email

    assert santander_user.valid?
    refute other_madrid_user.valid?
    assert other_madrid_user.errors.include? :email
  end

  def test_email_unique_capitalized
    new_user = User.new email: user.email.upcase, site: user.site
    refute new_user.valid?
    assert new_user.errors[:email].present?
  end

  def test_valid
    assert user.valid?
  end

  def test_age
    birthdate = Time.new(2004, 2, 29, 6, 0, 0)
    user.update_attribute(:date_of_birth, birthdate)

    Timecop.freeze(birthdate + 1.month) { assert_equal 0, user.age }
    Timecop.freeze(birthdate.change(year: 2005, day: 28)) { assert_equal 0, user.age }
    Timecop.freeze(birthdate.change(year: 2005, month: 3, day: 1)) { assert_equal 1, user.age }
  end

end
