# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoPlans < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_name: "gobierto_plans") }
  end
end
