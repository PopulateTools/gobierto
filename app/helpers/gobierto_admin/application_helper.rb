module GobiertoAdmin
  module ApplicationHelper
    def current_admin_label
      return unless current_admin

      admin_label_for(current_admin)
    end

    def admin_label_for(admin)
      return admin.name if admin.regular?

      "#{admin.name} (#{admin.authorization_level})"
    end

    def show_module_link?(module_namespace)
      SITE_MODULES.include?(module_namespace) && current_site && current_site.configuration.send(module_namespace.underscore + "_enabled?") &&
        current_admin.module_allowed?(module_namespace, current_site)
    end
  end
end
