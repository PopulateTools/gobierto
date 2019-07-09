# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoBudgets < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_type: "gobierto_budgets") }
  end
end
