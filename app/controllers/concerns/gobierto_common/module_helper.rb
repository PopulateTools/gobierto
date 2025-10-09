module GobiertoCommon
  module ModuleHelper
    extend ActiveSupport::Concern

    helper_method :admin_actions_manager

    def admin_actions_manager
      @admin_actions_manager ||= ::GobiertoAdmin::AdminActionsManager.for(current_admin_module, current_site)
    end

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

    def module_allowed_action!(action_name, module_namespace, resource = nil, admin = current_admin)
      ::GobiertoAdmin::AdminActionsManager.for(module_namespace, current_site).action_allowed?(admin:, action_name:, resource:)
    end

    def current_module_allowed_action!(action_name, resource = nil, admin = current_admin)
      raise_action_not_allowed unless admin_actions_manager.action_allowed?(admin:, action_name:, resource:)
    end
  end
end
