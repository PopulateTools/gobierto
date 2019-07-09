# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoBudgetConsultations < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_type: "gobierto_budget_consultations") }
  end
end
