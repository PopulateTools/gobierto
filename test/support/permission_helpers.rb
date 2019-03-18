# frozen_string_literal: true

module PermissionHelpers

  def grant_module_permissions_to_admin(admin, module_name)
    group = ::GobiertoAdmin::AdminGroup.find_or_create_by!(name: "#{admin.name} group")
    group.admins << admin unless group.admins.include? admin
    group.permissions.create!(
      namespace: "site_module",
      resource_name: module_name,
      action_name: "manage"
    )
  end

  def setup_specific_permissions(admin, options = {})
    ::GobiertoAdmin::AdminGroup.destroy_all unless options[:reset] == false

    group = ::GobiertoAdmin::AdminGroup.find_or_create_by!(name: "#{admin.name} group", site: options[:site])
    group.admins << admin unless group.admins.include? admin

    admin_sites = []
    admin_permissions = group.permissions

    admin_sites = [options[:site]] if options[:site]

    if options[:module]
      admin_permissions.build(
        namespace: "site_module",
        resource_name: options[:module],
        action_name: "manage"
      )
    end

    if options[:person]
      admin_permissions.build(
        namespace: "gobierto_people",
        resource_name: "person",
        resource_id: options[:person].id,
        action_name: "manage"
      )
    end

    if options[:all_people]
      admin_permissions.build(
        namespace: "gobierto_people",
        resource_name: "person",
        action_name: "manage_all"
      )
    end

    admin.sites = admin_sites
    group.save
    admin.save
  end

  def grant_templates_permission(admin, options = {})
    ::GobiertoAdmin::AdminGroup.destroy_all unless options[:reset] == false

    group = ::GobiertoAdmin::AdminGroup.find_or_create_by!(name: "#{admin.name} group", site: options[:site])
    group.admins << admin unless group.admins.include? admin

    admin_sites = []
    admin_permissions = group.permissions

    admin_sites = [options[:site]] if options[:site]

    admin_permissions.build(
      namespace: "site_options",
      resource_name: "templates",
      action_name: "manage"
    )
    admin.sites = admin_sites
    group.save
    admin.save
  end

  def revoke_templates_permission(admin)
    admin.site_options_permissions.where(
      resource_name: "templates",
      action_name: "manage"
    ).each(&:destroy)
  end

  def revoke_customize_site_permission(admin)
    admin.site_options_permissions.where(
      resource_name: "customize",
      action_name: "manage"
    ).each(&:destroy)
  end

end
