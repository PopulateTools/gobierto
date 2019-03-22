module GobiertoAdmin
  class BasePolicy

    attr_reader :current_admin, :current_site

    def initialize(attributes)
      @current_admin = attributes[:current_admin]
      @current_site  = attributes[:current_site]
    end

    def manage?
      return false if current_admin.disabled?
      return true  if current_admin.manager?
    end

    protected

    def can_manage_site?(site)
      current_admin.sites.exists?(site.id)
    end

    def can_manage_module?(module_namespace)
      current_admin.module_allowed?(module_namespace, current_site)
    end

  end
end