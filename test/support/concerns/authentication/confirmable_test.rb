module Authentication::ConfirmableTest
  def test_confirmed_scope
    subject = user.class.confirmed

    assert_includes subject, user
    refute_includes subject, unconfirmed_user
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
