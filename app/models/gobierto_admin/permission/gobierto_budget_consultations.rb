module GobiertoAdmin
  class Permission::GobiertoBudgetConsultations < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_budget_consultations")
    end
  end
end
