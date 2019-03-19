# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminFormTest < ActiveSupport::TestCase

    def richard
      @richard ||= gobierto_people_people(:richard)
    end

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

    def kali
      @kali ||= gobierto_people_people(:kali)
    end

    def madrid
      @madrid ||= sites(:madrid)
    end

    def santander
      @santander ||= sites(:santander)
    end

    def madrid_group
      @madrid_group ||= gobierto_admin_admin_groups(:madrid_group)
    end

    def santander_group
      @santander_group ||= gobierto_admin_admin_groups(:santander_group)
    end

    def admin_params
      @admin_params ||= {
        site: madrid,
        name: admin.name,
        email: new_admin_email, # to ensure uniqueness
        password: "gobierto",
        password_confirmation: "gobierto",
        authorization_level: "regular"
      }.with_indifferent_access
    end

    def manager_admin_params
      @manager_admin_params ||= admin_params.merge(authorization_level: "manager")
    end

    def valid_admin_form
      @valid_admin_form ||= AdminForm.new(manager_admin_params)
    end

    def invalid_admin_form
      @invalid_admin_form ||= AdminForm.new(
        name: nil,
        email: nil,
        password: nil,
        password_confirmation: nil
      )
    end

    def tony
      @tony ||= gobierto_admin_admins(:tony)
    end
    alias admin tony
    alias regular_admin tony
    alias madrid_and_santander_admin tony

    def steve
      @steve ||= gobierto_admin_admins(:steve)
    end
    alias only_madrid_admin steve

    def new_admin_email
      "wadus@gobierto.dev"
    end

    def test_save_with_valid_attributes
      assert valid_admin_form.save
    end

    def test_error_messages_with_valid_attributes_and_not_matching_passwords
      valid_admin_form.password_confirmation = "wadus"

      valid_admin_form.save

      assert_equal 0, valid_admin_form.errors.messages[:password].size
      assert_equal 1, valid_admin_form.errors.messages[:password_confirmation].size
    end

    def test_error_messages_with_invalid_attributes
      invalid_admin_form.save

      assert_equal 1, invalid_admin_form.errors.messages[:password].size
      assert_equal 0, invalid_admin_form.errors.messages[:password_confirmation].size
      assert_equal 1, invalid_admin_form.errors.messages[:name].size
      assert_equal 2, invalid_admin_form.errors.messages[:email].size
    end

    def test_confirmation_email_delivery_for_new_record
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        valid_admin_form.save
      end
    end

    def test_confirmation_email_delivery_for_existing_record
      admin_edit_form = AdminForm.new(id: admin.id, site: madrid)

      assert_no_difference "ActionMailer::Base.deliveries.size" do
        admin_edit_form.save
      end
    end

    ## Tests related to sites permissions

    def test_grant_site_permissions
      admin_form = AdminForm.new(
        admin_params.merge(
          id: only_madrid_admin.id,
          permitted_sites: [santander.id, madrid.id]
        )
      )

      assert admin_form.save

      admin_sites = only_madrid_admin.sites

      assert_equal 2, admin_sites.size

      assert admin_sites.include?(madrid)
      assert admin_sites.include?(santander)
    end

    def test_revoke_site_permissions
      admin_form = AdminForm.new(
        admin_params.merge(
          id: only_madrid_admin.id,
          permitted_sites: []
        )
      )

      assert admin_form.save

      assert only_madrid_admin.sites.empty?
    end

    def test_revoke_site_permissions_revokes_people_permissions
      admin_form = AdminForm.new(
        admin_params.merge(
          id: madrid_and_santander_admin.id,
          permitted_sites: [santander.id]
        )
      )

      assert_equal 2, madrid_and_santander_admin.people_permissions.size

      assert admin_form.save

      # assert site permissions were revoked
      assert_equal [santander], admin.sites

      # assert person permissions were revoked
      assert madrid_and_santander_admin.reload.people_permissions.empty?
    end

    def test_admin_groups_with_only_a_site
      admin_form = AdminForm.new(
        admin_params.merge(
          id: madrid_and_santander_admin.id,
          permitted_sites: [madrid.id],
          admin_group_ids: [madrid_group.id]
        )
      )

      assert admin_form.save

      assert_equal [madrid_group], madrid_and_santander_admin.admin_groups
    end

    def test_admin_groups_from_not_allowed_sites_are_deleted
      madrid_and_santander_admin.admin_groups = [madrid_group, santander_group]
      madrid_and_santander_admin.save

      admin_form = AdminForm.new(
        admin_params.merge(
          id: madrid_and_santander_admin.id,
          permitted_sites: [madrid.id],
          admin_group_ids: [madrid_group.id]
        )
      )

      assert_equal 2, madrid_and_santander_admin.reload.admin_groups.count

      assert admin_form.save

      assert_equal [madrid_group], madrid_and_santander_admin.reload.admin_groups
    end

    def test_admin_groups_from_other_allowed_sites_are_preserved
      madrid_and_santander_admin.admin_groups = [madrid_group, santander_group]
      madrid_and_santander_admin.save

      admin_form = AdminForm.new(
        admin_params.merge(
          id: madrid_and_santander_admin.id,
          permitted_sites: [madrid.id, santander.id],
          admin_group_ids: []
        )
      )

      assert_equal 2, madrid_and_santander_admin.reload.admin_groups.count

      assert admin_form.save

      assert_equal [santander_group], madrid_and_santander_admin.reload.admin_groups
    end
  end
end
