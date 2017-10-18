# frozen_string_literal: true

module PermissionHelpers

  def grant_module_permissions_to_admin(admin, module_name)
    ::GobiertoAdmin::Permission.create!(
      admin: admin,
      namespace: 'site_module',
      resource_name: module_name,
      action_name: 'manage'
    )
  end

  def setup_specific_permissions(admin, options = {})

    admin_sites = []
    admin_permissions = []

    admin_sites = [options[:site]] if options[:site]

    if options[:module]
      admin_permissions << admin.permissions.build(
        namespace: 'site_module',
        resource_name: options[:module],
        action_name: 'manage'
      )
    end

    if options[:person]
      admin_permissions << admin.permissions.build(
        namespace: 'gobierto_people',
        resource_name: 'person',
        resource_id: options[:person].id,
        action_name: 'manage'
      )
    end

    admin.sites = admin_sites
    admin.permissions = admin_permissions
    admin.save
  end

end
