# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class AdminInvitationAcceptanceTest < ActionDispatch::IntegrationTest
    def setup
      super
      @invitation_acceptance_path = admin_admin_invitation_acceptances_path(invitation_token: invited_admin.invitation_token)
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def invited_admin
      @invited_admin ||= gobierto_admin_admins(:steve)
    end

    def test_invitation_acceptance
      visit @invitation_acceptance_path

      assert has_message?('Signed in successfully')

      assert has_content?('Edit your data')

      fill_in :admin_password, with: 'gobierto'
      fill_in :admin_password_confirmation, with: 'gobierto'
      click_button 'Update'

      assert has_message?('Data updated successfully')
    end

    def test_invalid_invitation_acceptance
      visit admin_admin_invitation_acceptances_path(invitation_token: 'foo')

      assert has_message?("This URL doesn't seem to be valid")
    end

    def test_invitation_acceptance_when_already_signed_in
      with_signed_in_admin(admin) do
        visit @invitation_acceptance_path

        assert has_message?('You are already signed in')
      end
    end
  end
end
