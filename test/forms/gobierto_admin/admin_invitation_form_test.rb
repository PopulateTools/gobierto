require "test_helper"

module GobiertoAdmin
  class AdminInvitationFormTest < ActiveSupport::TestCase
    def valid_admin_invitation_form
      @valid_admin_invitation_form ||= AdminInvitationForm.new(
        emails: "one@gobierto.dev, two@gobierto.dev",
        site_ids: [site.id]
      )
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
end
