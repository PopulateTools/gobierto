# frozen_string_literal: true

module Authentication::ConfirmableTest
  def test_confirmed_scope
    subject = user.class.confirmed

    assert_includes subject, user
    refute_includes subject, unconfirmed_user
  end

  def test_unconfirmed_scope
    subject = user.class.unconfirmed

    assert_includes subject, unconfirmed_user
    refute_includes subject, user
  end

  def test_find_by_confirmation_token
    confirmation_token = unconfirmed_user.confirmation_token
    subject = unconfirmed_user.class.find_by(confirmation_token: confirmation_token)

    assert_equal unconfirmed_user, subject

    subject = unconfirmed_user.class.find_by(confirmation_token: nil)

    assert_nil subject
  end

  def test_confirmed?
    assert user.confirmed?
    refute unconfirmed_user.confirmed?
  end

  def test_confirm!
    refute unconfirmed_user.confirmed?

    unconfirmed_user.confirm!
    assert unconfirmed_user.confirmed?
  end
end
