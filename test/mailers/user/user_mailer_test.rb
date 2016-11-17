require "test_helper"

class User::UserMailerTest < ActionMailer::TestCase
  def user
    @user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_confirmation_instructions
    email = User::UserMailer.confirmation_instructions(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Confirmation instructions", email.subject
  end

  def test_reset_password_instructions
    email = User::UserMailer.reset_password_instructions(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Reset password instructions", email.subject
  end
end
