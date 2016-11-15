require "test_helper"

class Admin::AdminMailerTest < ActionMailer::TestCase
  def admin
    @admin ||= admins(:tony)
  end

  def test_confirmation_instructions
    email = Admin::AdminMailer.confirmation_instructions(admin).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [admin.email], email.to
    assert_equal "[Admin] Confirmation instructions", email.subject
  end

  def test_invitation_instructions
    email = Admin::AdminMailer.invitation_instructions(admin).deliver_now

    refute ActionMailer::Base.deliveries.empty?

    assert_equal ["admin@gobierto.dev"], email.from
    assert_equal ["admin@gobierto.dev"], email.reply_to
    assert_equal [admin.email], email.to
    assert_equal "[Admin] Invitation instructions", email.subject
  end
end
