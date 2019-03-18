# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPolicyTest < ActiveSupport::TestCase

      include PermissionHelpers

      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:tony)
      end

      def manager_admin
        @manager_admin ||= gobierto_admin_admins(:nick)
      end

      def disabled_admin
        @disabled_admin ||= gobierto_admin_admins(:podrick)
      end

      def richard
        @richard ||= gobierto_people_people(:richard)
      end
      alias published_person richard
      alias person richard

      def juana
        @juana ||= gobierto_people_people(:juana)
      end
      alias draft_person juana

      def nelson
        @nelson ||= gobierto_people_people(:nelson)
      end

      def madrid
        sites(:madrid)
      end
      alias site madrid

      def santander
        sites(:santander)
      end

      def madrid_group
        @madrid_group ||= gobierto_admin_groups(:madrid_group)
      end

      def test_manager_admin_manage?
        remove_admin_groups

        assert PersonPolicy.new(current_admin: manager_admin, person: published_person).manage?
        assert PersonPolicy.new(current_admin: manager_admin, person: draft_person).manage?
      end

      def test_regular_admin_manage?
        # with all permissions
        setup_specific_permissions(regular_admin, site: site, module: "gobierto_people", person: person)
        assert PersonPolicy.new(current_admin: regular_admin, person: person).manage?

        # without site permissions
        setup_specific_permissions(regular_admin, module: "gobierto_people", person: person)
        refute PersonPolicy.new(current_admin: regular_admin, person: person).manage?

        # without module permissions
        setup_specific_permissions(regular_admin, site: site, person: person)
        refute PersonPolicy.new(current_admin: regular_admin, person: person).manage?

        # without person permissions
        setup_specific_permissions(regular_admin, site: site, module: "gobierto_people")
        refute PersonPolicy.new(current_admin: regular_admin, person: person).manage?
      end

      def test_disabled_admin_manage?
        # with all permissions
        setup_specific_permissions(disabled_admin, site: site, module: "gobierto_people", person: person)
        refute PersonPolicy.new(current_admin: disabled_admin, person: person).manage?
      end

      def test_view?
        remove_admin_groups

        assert PersonPolicy.new(current_admin: manager_admin, person: published_person).view?
        assert PersonPolicy.new(current_admin: manager_admin, person: draft_person).view?

        assert PersonPolicy.new(current_admin: regular_admin, person: published_person).view?
        refute PersonPolicy.new(current_admin: regular_admin, person: draft_person).view?

        assert PersonPolicy.new(current_admin: disabled_admin, person: published_person).view?
        refute PersonPolicy.new(current_admin: disabled_admin, person: draft_person).view?
      end

      def test_create?
        remove_admin_groups

        assert PersonPolicy.new(current_admin: manager_admin, current_site: site).create?
        refute PersonPolicy.new(current_admin: disabled_admin, current_site: site).create?

        # with all permissions
        setup_specific_permissions(regular_admin, site: site, module: "gobierto_people", all_people: true)
        assert PersonPolicy.new(current_admin: regular_admin, current_site: site).create?

        # with manage_all permissions, but on other site
        setup_specific_permissions(regular_admin, site: santander, module: "gobierto_people", all_people: true)
        refute PersonPolicy.new(current_admin: regular_admin, current_site: site).create?

        # without module permissions
        setup_specific_permissions(regular_admin, site: site, all_people: true)

        refute PersonPolicy.new(current_admin: regular_admin, current_site: site).create?

        # without manage_all permissions
        setup_specific_permissions(regular_admin, site: site, module: "gobierto_people")
        refute PersonPolicy.new(current_admin: regular_admin, current_site: site).create?
      end

      def test_manage_all_people_in_site?
        remove_admin_groups

        refute PersonPolicy.new(current_admin: disabled_admin, current_site: site).manage_all_people_in_site?
        assert PersonPolicy.new(current_admin: manager_admin, current_site: site).manage_all_people_in_site?
        refute PersonPolicy.new(current_admin: regular_admin, current_site: site).manage_all_people_in_site?

        setup_specific_permissions(regular_admin, site: site, module: "gobierto_people", all_people: true)
        assert PersonPolicy.new(current_admin: regular_admin, current_site: site).manage_all_people_in_site?
      end

      def test_multiple_groups_permissions
        refute PersonPolicy.new(current_admin: regular_admin, current_site: site).manage_all_people_in_site?
        assert PersonPolicy.new(current_admin: regular_admin, person: person).manage?

        setup_specific_permissions(regular_admin, site: site, module: "gobierto_people", all_people: true, reset: false)

        assert PersonPolicy.new(current_admin: regular_admin, current_site: site).manage_all_people_in_site?
        assert PersonPolicy.new(current_admin: regular_admin, person: person).manage?
      end

      private

      def remove_admin_groups
        GobiertoAdmin::AdminGroup.destroy_all
      end
    end
  end
end
