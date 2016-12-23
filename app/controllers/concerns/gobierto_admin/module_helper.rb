module GobiertoAdmin
  module ModuleHelper
    extend ActiveSupport::Concern

    private

    def module_enabled!(site, module_namespace)
      raise_module_not_enabled unless site.configuration.modules.include?(module_namespace.to_s)
    end

    protected

    def raise_module_not_enabled
      redirect_to(
        admin_root_path,
        alert: t("gobierto_admin.module_helper.not_enabled")
      )
    end
  end
end
