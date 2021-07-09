# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminGroupFormTest < ActiveSupport::TestCase

    def subject
      @subject = AdminGroupForm
    end

    def madrid_group
      @madrid_group ||= gobierto_admin_admin_groups(:madrid_group)
    end

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

    def admin_group_params
      @admin_group_params ||= {
      }.with_indifferent_access
    end

    def madrid_group_params
      @madrid_group_params ||= { id: madrid_group.id, name: "Test group", site_id: madrid.id }
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

    def test_invalid_params
      form = subject.new

      refute form.save
    end

    def test_modules_initialization
      assert_equal({}, subject.new.modules_actions)
    end

    ## Tests related to permissions

    def test_change_authorization_level_updates_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage] },
          people: [richard.id]
        )
      )

      assert form.save
      assert only_madrid_admin.permissions.empty?

      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage] },
          people: [richard.id]
        )
      )

      assert form.save
      assert only_madrid_admin.permissions.empty?
    end

    def test_grant_module_permissions
      form = subject.new(madrid_group_params.merge(modules_actions: { gobierto_people: [:manage],
                                                                      gobierto_participation: [:manage],
                                                                      gobierto_plans: [:manage],
                                                                      gobierto_investments: [:manage],
                                                                      gobierto_data: [:manage],
                                                                      gobierto_visualizations: [:manage] }))

      assert_equal 5, tony.modules_permissions.size

      assert form.save

      assert_equal 6, tony.modules_permissions.size
    end

    def test_revoke_module_permissions
      form = subject.new(madrid_group_params.merge(modules_actions: { gobierto_people: [:manage] }))

      assert_equal 5, tony.modules_permissions.size

      assert form.save

      assert_equal 1, tony.modules_permissions.size
    end

    # Using the syntax .where("x NOT IN (?)", collection) may have unintended behavior
    # for empty collections.
    # Use this test to make sure .where.not(attribute: collection) syntax is used
    def test_revoke_all_module_permissions
      form = subject.new(madrid_group_params.merge(modules_actions: {}))

      assert form.save

      assert tony.modules_permissions.empty?
    end

    def test_revoke_gobierto_people_permissions_revokes_people_permissions
      form = subject.new(madrid_group_params.merge(modules_actions: { gobierto_budget_consultations: [:manage] }))

      assert form.save

      assert madrid_and_santander_admin.people_permissions.empty?
    end

    def test_grant_person_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage], gobierto_budget_consultations: [:manage] },
          people: [richard.id, tamara.id, kali.id]
        )
      )

      assert form.save

      assert_equal 3, madrid_and_santander_admin.people_permissions.size
    end

    def test_grant_all_people_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage] },
          people: [],
          all_people: "1"
        )
      )

      assert form.save

      people_permissions = madrid_and_santander_admin.people_permissions

      assert_equal 1, people_permissions.size
      assert_equal "manage_all", people_permissions.first.action_name
    end

    def test_grant_person_permissions_without_site_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage], gobierto_budget_consultations: [:manage] },
          people: [richard.id, tamara.id, kali.id]
        )
      )

      assert form.save

      assert_equal 3, madrid_and_santander_admin.people_permissions.size
      assert_equal 3, madrid_and_santander_admin.sites_people_permissions.size

      only_madrid_admin.admin_groups << madrid_group
      assert_equal 3, only_madrid_admin.people_permissions.size
      assert_equal 2, only_madrid_admin.sites_people_permissions.size
    end

    def test_grant_person_permissions_without_gobierto_people_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_budget_consultations: [:manage] },
          people: [richard.id, kali.id, tamara.id]
        )
      )

      assert form.save

      assert madrid_and_santander_admin.people_permissions.empty?
    end

    def test_revoke_person_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage] },
          people: [richard.id]
        )
      )

      assert form.save

      assert_equal 1, madrid_and_santander_admin.people_permissions.size
    end

    def test_revoke_all_people_permissions
      form = subject.new(
        madrid_group_params.merge(
          modules_actions: { gobierto_people: [:manage] },
          people: [],
          all_people: "0"
        )
      )

      assert form.save

      assert madrid_and_santander_admin.people_permissions.empty?
    end

    def test_grant_site_options_permissions
      form = subject.new(madrid_group_params.merge(site_options: %w(customize vocabularies templates custom_fields)))

      assert_equal 3, tony.site_options_permissions.size

      assert form.save

      assert_equal 4, tony.site_options_permissions.size
    end

    def test_revoke_site_options_permissions
      form = subject.new(madrid_group_params.merge(site_options: %w(templates)))

      assert_equal 3, tony.site_options_permissions.size

      assert form.save

      assert_equal 1, tony.site_options_permissions.size
    end
  end
end
