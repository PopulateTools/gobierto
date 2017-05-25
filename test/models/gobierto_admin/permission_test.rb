# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class PermissionTest < ActiveSupport::TestCase
    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def admin_permission
      @admin_permission ||= gobierto_admin_permissions(:tony_create)
    end

    def test_valid
      assert admin_permission.valid?
    end

    # -- Class methods
    def test_by_namespace
      assert_includes admin.global_permissions.by_namespace('global').pluck(:id), admin_permission.id
    end

    def test_by_resource
      assert_includes admin.global_permissions.by_resource('global').pluck(:id), admin_permission.id
    end

    def test_resource_names
      assert_includes admin.global_permissions.resource_names, 'global'
    end

    def test_action_names
      assert_includes admin.global_permissions.action_names, 'create'
    end

    def test_can?
      assert admin.global_permissions.can?('create')
    end

    def test_grant
      assert_difference 'Permission.count', 1 do
        admin.global_permissions.grant('update')
      end

      assert admin.global_permissions.can?('update')
    end

    def test_deny
      admin.global_permissions.grant('update')
      assert admin.global_permissions.can?('update')

      assert_difference 'Permission.count', -1 do
        admin.global_permissions.deny('update')
      end

      refute admin.global_permissions.can?('update')
    end
  end
end
