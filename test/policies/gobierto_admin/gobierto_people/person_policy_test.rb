# frozen_string_literal: true

require 'test_helper'

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
        @nelson ||= gobierto_people_people(:juana)
      end
      alias draft_person juana

      def madrid
        sites(:madrid)
      end
      alias site madrid

      def test_manage?
        assert PersonPolicy.new(manager_admin, published_person).manage?
        assert PersonPolicy.new(manager_admin, draft_person).manage?

        # manager with all permissions
        setup_specific_permissions(regular_admin, site: site, module: 'gobierto_people', person: person)
        assert PersonPolicy.new(regular_admin, person).manage?

        # manager without site permissions
        setup_specific_permissions(regular_admin, module: 'gobierto_people', person: person)
        refute PersonPolicy.new(regular_admin, person).manage?

        # manager without module permissions
        setup_specific_permissions(regular_admin, site: site, person: person)
        refute PersonPolicy.new(regular_admin, person).manage?

        # manager without person permissions
        setup_specific_permissions(regular_admin, site: site, module: 'gobierto_people')
        refute PersonPolicy.new(regular_admin, person).manage?

        # disabled with all permissions
        setup_specific_permissions(disabled_admin, site: site, module: 'gobierto_people', person: person)
        refute PersonPolicy.new(disabled_admin, person).manage?
      end

      def test_view?
        assert PersonPolicy.new(manager_admin, published_person).view?
        assert PersonPolicy.new(manager_admin, draft_person).view?

        assert PersonPolicy.new(regular_admin, published_person).view?
        refute PersonPolicy.new(regular_admin, draft_person).view?

        assert PersonPolicy.new(disabled_admin, published_person).view?
        refute PersonPolicy.new(disabled_admin, draft_person).view?
      end

      def test_create?
        assert PersonPolicy.new(manager_admin).create?
        refute PersonPolicy.new(regular_admin).create?
        refute PersonPolicy.new(disabled_admin).create?
      end

    end
  end
end
