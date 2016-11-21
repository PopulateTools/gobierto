require "test_helper"

class Admin::UserMailerTest < ActionMailer::TestCase
  def user
    @user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_confirmation_instructions
    email = Admin::UserMailer.confirmation_instructions(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "[Admin] Confirmation instructions", email.subject
  end

  def test_reset_password_instructions
    email = Admin::UserMailer.reset_password_instructions(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "[Admin] Reset password instructions", email.subject
  end

  def test_welcome
    email = Admin::UserMailer.welcome(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "[Admin] Welcome to Gobierto", email.subject
  end
end
