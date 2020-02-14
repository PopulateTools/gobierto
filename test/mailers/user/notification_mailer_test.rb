# frozen_string_literal: true

require "test_helper"

class User::NotificationMailerTest < ActionMailer::TestCase

  attr_accessor(
    :user_notification,
    :user,
    :organization_email
  )

  def setup
    super
    @user_notification = user_notifications(:dennis_consultation_created)
    @user = user_notification.user
    @organization_email = sites(:madrid).organization_email
  end

  def test_single_notification
    email = User::NotificationMailer.single_notification(user_notification).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal [organization_email], email.from
    assert_nil email.reply_to
    assert_equal [user.email], email.to
    assert_equal "New activity in Ayuntamiento de Madrid: Consulta sobre los presupuestos de Madrid", email.subject
  end

  def test_notification_digest
    email = User::NotificationMailer.notification_digest(user, [user_notification], :daily).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal [organization_email], email.from
    assert_nil email.reply_to
    assert_equal [user.email], email.to
    assert_equal "Activity summary from Ayuntamiento de Madrid", email.subject
  end
end
