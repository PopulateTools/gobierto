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

    def madrid
      @madrid ||= sites(:madrid)
    end

    def santander
      @santander ||= sites(:santander)
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

    def test_regular_admin_without_admins_permission_is_redirected_from_invitations
      with_signed_in_admin(regular_admin) do
        visit @new_invitation_path

        assert_current_path admin_users_path
        assert has_no_field?(:admin_invitation_emails)
      end
    end

    def test_regular_admin_with_admins_permission_sees_invitation_link
      grant_admins_permission_to_regular_admin

      with_signed_in_admin(regular_admin) do
        visit admin_admins_path

        assert has_link?("Send invitations")
        assert has_link?("Groups and permissions")
      end
    end

    def test_regular_admin_with_admins_permission_only_invites_on_managed_sites
      grant_admins_permission_to_regular_admin

      with_signed_in_admin(regular_admin) do
        visit @new_invitation_path

        # Regular admin steve only manages madrid -> sites selector is hidden
        # and the single site is submitted as a hidden input.
        assert has_no_selector?(".site-check-boxes")
        assert has_selector?("input[type=hidden][name='admin_invitation[site_ids][]']", visible: false, count: 1)

        fill_in :admin_invitation_emails, with: "foo@gobierto.dev"
        click_on "Send"

        assert has_message?("The invitations have been successfully sent")
      end
    end
  end
end
