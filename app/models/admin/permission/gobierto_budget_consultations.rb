class Admin::Permission::GobiertoBudgetConsultations < Admin::Permission
  default_scope -> do
    where(namespace: "site_module", resource_name: "gobierto_budget_consultations")
  end
end
