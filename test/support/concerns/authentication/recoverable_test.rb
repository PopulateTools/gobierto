# frozen_string_literal: true

module Authentication::RecoverableTest
  def test_recoverable_scope
    subject = recoverable_user.class.recoverable

    assert_includes subject, recoverable_user
    refute_includes subject, not_recoverable_user
  end

  def test_find_by_reset_password_token
    reset_password_token = recoverable_user.reset_password_token
    subject = recoverable_user.class.find_by_reset_password_token(reset_password_token)

    assert_equal recoverable_user, subject

    subject = recoverable_user.class.find_by_reset_password_token(nil)

    assert_nil subject
  end

  def test_recoverable?
    assert recoverable_user.recoverable?
    refute not_recoverable_user.recoverable?
  end

  def test_recovered!
    assert recoverable_user.recoverable?

    recoverable_user.recovered!
    refute recoverable_user.recoverable?
  end
end
