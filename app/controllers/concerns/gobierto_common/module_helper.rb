module GobiertoCommon
  module ModuleHelper
    extend ActiveSupport::Concern

    private

    def gobierto_module_enabled!(site, module_namespace, redirect = true)
      puts "\n\n\n[RESULT] #{site.configuration.modules.include?(module_namespace.to_s)}\n\n\n"
      raise_module_not_enabled(redirect) unless site.configuration.modules.include?(module_namespace.to_s)
    end

    def module_allowed!(current_admin, module_namespace)
      raise_module_not_allowed unless current_admin.module_allowed?(module_namespace)
    end

  end
end
