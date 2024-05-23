# frozen_string_literal: true

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

    assert_equal ["no-reply@gobierto.dev"], email.from
    assert_equal [site.reply_to_email], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Complete your registration in Ayuntamiento de Madrid", email.subject
  end

  def test_reset_password_instructions
    email = User::UserMailer.reset_password_instructions(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["no-reply@gobierto.dev"], email.from
    assert_equal [site.reply_to_email], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Reset your password", email.subject
  end

  def test_welcome
    email = User::UserMailer.welcome(user, site).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["no-reply@gobierto.dev"], email.from
    assert_equal [site.reply_to_email], email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Welcome", email.subject
  end

  def test_without_reply_to_email
    site.update!(reply_to_email: nil)

    email = User::UserMailer.welcome(user, site).deliver_now

    assert_equal ["no-reply@gobierto.dev"], email.from
    assert_nil email.reply_to
  end
end
