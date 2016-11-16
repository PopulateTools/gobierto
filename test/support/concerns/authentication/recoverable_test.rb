module Authentication::RecoverableTest
  def test_recoverable_scope
    subject = user.class.recoverable

    assert_includes subject, recoverable_user
    refute_includes subject, user
  end

  def test_recoverable?
    assert recoverable_user.recoverable?
    refute user.recoverable?
  end

  def test_recovered!
    assert recoverable_user.recoverable?

    recoverable_user.recovered!
    refute recoverable_user.recoverable?
  end
end
