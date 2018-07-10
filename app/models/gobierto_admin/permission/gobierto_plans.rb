# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoPlans < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_plans")
    end
  end
end
