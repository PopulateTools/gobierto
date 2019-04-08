module GobiertoCommon
  module ModuleHelper
    extend ActiveSupport::Concern

    private

    def module_enabled!(site, module_namespace, redirect = true)
      raise_module_not_enabled(redirect) unless site.configuration.modules.include?(module_namespace.to_s)
    end

    def module_allowed!(current_admin, module_namespace)
      raise_module_not_allowed unless current_admin.module_allowed?(module_namespace, current_site)
    end

    def module_allowed_action!(current_admin, module_namespace, action)
      raise_module_not_allowed unless current_admin.module_allowed_action?(module_namespace, current_site, action)
    end

  end
end
