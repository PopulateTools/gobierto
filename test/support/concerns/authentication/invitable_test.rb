module Authentication::InvitableTest
  def test_invitations_scope
    subject = user.class.invitation

    assert_includes subject, invited_user
    refute_includes subject, user
  end

  def test_invitation_pending_scope
    subject = user.class.invitation_pending

    assert_includes subject, invited_user
    refute_includes subject, user
  end

  def test_invitation_accepted_scope
    invited_user.update_columns(invitation_token: nil)

    subject = user.class.invitation_accepted

    assert_includes subject, invited_user
    refute_includes subject, user
  end

  def test_invitation?
    assert invited_user.invitation?
    refute user.invitation?
  end

  def test_invitation_pending?
    assert invited_user.invitation_pending?
    refute user.invitation_pending?
  end

  def test_invitation_accepted?
    assert invited_user.invitation_pending?
    refute user.invitation_pending?

    invited_user.invitation_token = nil
    refute invited_user.invitation_pending?
    refute user.invitation_pending?
  end

  def test_accept_invitation!
    refute invited_user.invitation_accepted?

    invited_user.accept_invitation!
    assert invited_user.invitation_accepted?
  end
end
