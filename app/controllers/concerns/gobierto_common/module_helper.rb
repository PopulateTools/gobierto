module GobiertoCommon
  module ModuleHelper
    extend ActiveSupport::Concern

    private

    def module_enabled?(module_namespace, site = nil)
      site ||= current_site
      site.configuration.modules.include?(module_namespace.to_s)
    end

    def module_enabled!(site, module_namespace, redirect = true)
      raise_module_not_enabled(redirect) unless module_enabled?(module_namespace, site)
    end

    def module_frontend_enabled!(site, module_namespace, redirect = true)
      raise_module_not_enabled(redirect) unless site.configuration.modules_with_frontend_enabled.include?(module_namespace.to_s)
    end

    def module_allowed!(current_admin, module_namespace)
      raise_module_not_allowed unless current_admin.module_allowed?(module_namespace, current_site)
    end

    def module_allowed_action!(current_admin, module_namespace, action)
      raise_action_not_allowed unless current_admin.module_allowed_action?(module_namespace, current_site, action)
    end

  end
end
