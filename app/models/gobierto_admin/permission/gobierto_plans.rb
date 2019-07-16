# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoPlans < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_type: "gobierto_plans") }
  end
end
