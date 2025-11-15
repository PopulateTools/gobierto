# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class GroupPermissionTest < ActiveSupport::TestCase
    def group
      @group ||= gobierto_admin_admin_groups(:madrid_group)
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def subject_class
      @subject_class ||= GroupPermission
    end

    def group_permission
      @group_permission ||= gobierto_admin_group_permissions(:madrid_create)
    end

    def test_valid
      assert group_permission.valid?
    end

    # -- Class methods
    def test_by_namespace
      assert_includes subject_class.by_namespace("global").pluck(:id), group_permission.id
    end

    def test_by_resource
      assert_includes subject_class.by_resource("global").pluck(:id), group_permission.id
    end

    def test_resource_types
      assert_includes subject_class.resource_types, "global"
    end

    def test_action_names
      assert_includes subject_class.action_names, "create_projects"
    end

    def test_can?
      assert subject_class.can?("create_projects")
    end

    def test_grant
      assert_difference "GroupPermission.count", 1 do
        group.global_permissions.grant("update")
      end

      assert subject_class.can?("update")
    end

    def test_deny
      group.global_permissions.grant("update")
      assert subject_class.can?("update")

      assert_difference "GroupPermission.count", -1 do
        group.global_permissions.deny("update")
      end

      refute subject_class.can?("update")
    end
  end
end
