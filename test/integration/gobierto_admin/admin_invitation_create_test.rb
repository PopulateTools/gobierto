# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminInvitationCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @new_invitation_path = new_admin_admin_invitations_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_invitation_create
      with_signed_in_admin(admin) do
        visit @new_invitation_path

        fill_in :admin_invitation_emails, with: "foo@gobierto.dev, bar@gobierto.dev"

        within ".site-check-boxes" do
          check "madrid.gobierto.test"
        end

        click_on "Send"

        assert has_message?("The invitations have been successfully sent")
      end
    end

    def test_invalid_invitation
      with_signed_in_admin(admin) do
        visit @new_invitation_path

        fill_in :admin_invitation_emails, with: "foo@gobierto.dev, bar@gobierto.dev"

        click_on "Send"

        assert has_content?("There was a problem sending the invitations")
      end
    end
  end
end
