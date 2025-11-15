# frozen_string_literal: true

module GobiertoAdmin
  module PermissionsGroupHelpers
    extend ActiveSupport::Concern

    def set_permissions_group(resource, options = {})
      action_name = options.key?(:action_name) ? options[:action_name] : "manage"

      group = site.admin_groups.find_or_create_by(resource: resource, name: "resource_group_#{resource.class.name}_#{resource.id}", group_type: :system)

      if action_name.present?
        group.permissions.find_or_create_by(
          namespace: resource.class.name.deconstantize.underscore,
          resource: resource,
          action_name: action_name
        )
      end

      yield(group) if block_given?
    end
  end
end
