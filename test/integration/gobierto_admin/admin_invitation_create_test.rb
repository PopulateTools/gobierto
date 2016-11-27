require "test_helper"

module GobiertoAdmin
  class AdminInvitationCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @new_invitation_path = new_admin_admin_invitations_path
    end

    def admin
      @admin ||= admins(:tony)
    end

    def test_invitation_create
      with_signed_in_admin(admin) do
        visit @new_invitation_path

        fill_in :admin_invitation_emails, with: "foo@gobierto.dev, bar@gobierto.dev"

        within ".site-check-boxes" do
          check "madrid.gobierto.dev"
        end

        click_on "Send"

        assert has_content?("The invitations have been successfully sent.")
      end
    end
  end
end
