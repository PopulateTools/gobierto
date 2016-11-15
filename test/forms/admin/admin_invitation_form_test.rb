require "test_helper"

class Admin::AdminInvitationFormTest < ActiveSupport::TestCase
  def valid_admin_invitation_form
    @valid_admin_invitation_form ||= Admin::AdminInvitationForm.new(
      admin_id: admin.id,
      emails: "one@gobierto.dev, two@gobierto.dev",
      site_ids: [site.id]
    )
  end

  def admin
    @admin ||= admins(:tony)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_validation
    assert valid_admin_invitation_form.valid?
  end

  def test_process
    assert valid_admin_invitation_form.process
  end
end
