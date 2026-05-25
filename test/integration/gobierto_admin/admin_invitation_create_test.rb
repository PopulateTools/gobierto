# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminInvitationCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @new_invitation_path = new_admin_admin_invitations_path
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:steve)
    end

    def madrid_group
      @madrid_group ||= gobierto_admin_admin_groups(:madrid_group)
    end

    def grant_admins_permission_to_regular_admin
      GobiertoAdmin::GroupPermission.create!(
        admin_group: madrid_group,
        namespace: "site_options",
        resource_type: "admins",
        action_name: "manage"
      )
      GobiertoAdmin::GroupsAdmin.create!(admin: regular_admin, admin_group: madrid_group)
    end

    def test_invitation_create
      with_signed_in_admin(manager_admin) do
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
      with_signed_in_admin(manager_admin) do
        visit @new_invitation_path

        fill_in :admin_invitation_emails, with: "foo@gobierto.dev, bar@gobierto.dev"

        click_on "Send"

        assert has_content?("There was a problem sending the invitations")
      end
    end

    def test_regular_admin_with_admins_permission_does_not_see_invitation_link
      grant_admins_permission_to_regular_admin

      with_signed_in_admin(regular_admin) do
        visit admin_admins_path

        assert has_no_link?("Send invitations")
        assert has_no_link?("Groups and permissions")
      end
    end
  end
end
