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

    def admin_params
      @admin_params ||= {
        name: admin.name,
        email: new_admin_email, # to ensure uniqueness
        password: 'gobierto',
        password_confirmation: 'gobierto',
        authorization_level: 'regular'
      }.with_indifferent_access
    end

    def manager_admin_params
      @manager_admin_params ||= admin_params.merge(authorization_level: 'manager')
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
    alias_method :admin, :tony
    alias_method :regular_admin, :tony
    alias_method :madrid_and_santander_admin, :tony

    def steve
      @steve ||= gobierto_admin_admins(:steve)
    end
    alias_method :only_madrid_admin, :steve

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

    def test_permitted_modules_initialization
      assert_equal [], AdminForm.new.permitted_modules
    end

    def test_confirmation_email_delivery_for_new_record
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        valid_admin_form.save
      end
    end

    def test_confirmation_email_delivery_for_existing_record
      admin_edit_form = AdminForm.new(id: admin.id)

      assert_no_difference "ActionMailer::Base.deliveries.size" do
        admin_edit_form.save
      end
    end

    ## Tests related to permissions

    def test_change_authorization_level_updates_permissions

      admin_form = AdminForm.new(admin_params.merge(
        id: only_madrid_admin.id,
        authorization_level: 'disabled',
        permitted_modules: [ 'GobiertoPeople' ],
        permitted_sites: [ madrid.id],
        permitted_people: [ richard.id ]
      ))

      # disabled admins don't have permissions at all

      assert admin_form.save
      assert only_madrid_admin.permissions.empty?
      assert only_madrid_admin.sites.empty?

      admin_form = AdminForm.new(admin_params.merge(
        id: only_madrid_admin.id,
        authorization_level: 'manager',
        permitted_modules: [ 'GobiertoPeople' ],
        permitted_sites: [ madrid.id],
        permitted_people: [ richard.id ]
      ))

      # manager admins don't need sites or permission objects

      assert admin_form.save
      assert only_madrid_admin.permissions.empty?
      assert only_madrid_admin.sites.empty?
    end

    def test_grant_site_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: only_madrid_admin.id,
        permitted_sites: [ santander.id, madrid.id ]
      ))

      assert admin_form.save

      admin_sites = only_madrid_admin.sites

      assert_equal 2, admin_sites.size

      assert admin_sites.include?(madrid)
      assert admin_sites.include?(santander)
    end

    def test_revoke_site_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: only_madrid_admin.id,
        permitted_sites: []
      ))

      assert admin_form.save

      assert only_madrid_admin.sites.empty?
    end

    def test_revoke_site_permissions_revokes_people_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoPeople'],
        permitted_sites: [santander.id]
      ))

      assert_equal 2, madrid_and_santander_admin.people_permissions.size

      assert admin_form.save

      # assert site permissions were revoked
      assert_equal [santander], admin.sites

      # assert person permissions were revoked
      assert madrid_and_santander_admin.people_permissions.empty?
    end

    def test_grant_module_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: tony.id,
        permitted_modules: ['GobiertoPeople', 'GobiertoBudgetConsultations' , 'GobiertoParticipation']
      ))

      assert_equal 2, tony.modules_permissions.size

      assert admin_form.save

      assert_equal 3, tony.modules_permissions.size
    end

    def test_revoke_module_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: tony.id,
        permitted_modules: ['GobiertoPeople']
      ))

      assert_equal 2, tony.modules_permissions.size

      assert admin_form.save

      assert_equal 1, tony.modules_permissions.size
    end

    # Using the syntax .where("x NOT IN (?)", collection) may have unintended behavior
    # for empty collections.
    # Use this test to make sure .where.not(attribute: collection) syntax is used
    def test_revoke_all_module_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: tony.id,
        permitted_modules: []
      ))

      assert admin_form.save

      assert tony.modules_permissions.empty?
    end

    def test_revoke_gobierto_people_permissions_revokes_people_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoBudgetConsultations'],
        permitted_sites: [ madrid.id, santander.id ]
      ))

      assert admin_form.save

      assert madrid_and_santander_admin.people_permissions.empty?
    end

    def test_grant_person_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoPeople', 'GobiertoBudgetConsultations'],
        permitted_sites: [ madrid.id, santander.id ],
        permitted_people: [richard.id, tamara.id, kali.id]
      ))

      assert admin_form.save

      assert_equal 3, madrid_and_santander_admin.people_permissions.size
    end

    def test_grant_all_people_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoPeople'],
        permitted_sites: [ madrid.id ],
        permitted_people: [],
        all_people_permitted: 'on'
      ))

      assert admin_form.save

      assert_equal madrid.people.active.size, madrid_and_santander_admin.people_permissions.size
    end

    def test_grant_person_permissions_without_site_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoPeople', 'GobiertoBudgetConsultations'],
        permitted_sites: [ madrid.id ],
        permitted_people: [richard.id, tamara.id, kali.id]
      ))

      assert admin_form.save

      assert_equal 2, madrid_and_santander_admin.people_permissions.size
    end

    def test_grant_person_permissions_without_gobierto_people_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoBudgetConsultations'],
        permitted_sites: [ madrid.id, santander.id ],
        permitted_people: [richard.id, kali.id, tamara.id]
      ))

      assert admin_form.save

      assert madrid_and_santander_admin.people_permissions.empty?
    end

    def test_revoke_person_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoPeople'],
        permitted_sites: [ madrid.id, santander.id ],
        permitted_people: [richard.id]
      ))

      assert admin_form.save

      assert_equal 1, madrid_and_santander_admin.people_permissions.size
    end

    # Using the syntax .where("x NOT IN (?)", collection) may have unintended behavior
    # for empty collections.
    # Use this test to make sure .where.not(attribute: collection) syntax is used
    def test_revoke_all_people_permissions
      admin_form = AdminForm.new(admin_params.merge(
        id: madrid_and_santander_admin.id,
        permitted_modules: ['GobiertoPeople'],
        permitted_sites: [ madrid.id, santander.id ],
        permitted_people: []
      ))

      assert admin_form.save

      assert madrid_and_santander_admin.people_permissions.empty?
    end

  end
end
