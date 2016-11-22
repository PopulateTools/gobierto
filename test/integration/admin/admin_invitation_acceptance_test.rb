require "test_helper"

class Admin::AdminInvitationAcceptanceTest < ActionDispatch::IntegrationTest
  def setup
    super
    @invitation_acceptance_path = admin_admin_invitation_acceptances_path(invitation_token: admin.invitation_token)
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_invitation_acceptance
    visit @invitation_acceptance_path

    assert has_content?("Signed in successfully.")
  end

  def test_invalid_invitation_acceptance
    visit admin_admin_invitation_acceptances_path(invitation_token: "foo")

    assert has_content?("This URL doesn't seem to be valid.")
  end

  def test_invitation_acceptance_when_already_signed_in
    with_signed_in_admin(admin) do
      visit @invitation_acceptance_path

      assert has_content?("You are already signed in.")
    end
  end
end
