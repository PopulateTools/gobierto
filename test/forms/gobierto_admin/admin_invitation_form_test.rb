# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class AdminInvitationFormTest < ActiveSupport::TestCase
    def valid_admin_invitation_form
      @valid_admin_invitation_form ||= AdminInvitationForm.new(
        emails: 'one@gobierto.dev, two@gobierto.dev',
        site_ids: [site.id]
      )
    end

    def invalid_admin_invitation_form
      @invalid_admin_invitation_form ||= AdminInvitationForm.new(
        emails: "one@gobierto.dev, #{admin.email}",
        site_ids: [site.id]
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_validation
      assert valid_admin_invitation_form.valid?
    end

    def test_process
      assert valid_admin_invitation_form.process
      assert_equal 2, valid_admin_invitation_form.delivered_email_addresses.size
    end

    def test_invalid_process
      assert invalid_admin_invitation_form.process
      assert_equal 1, invalid_admin_invitation_form.delivered_email_addresses.size
    end
  end
end
