class Admin::Permission::GobiertoBudgets < Admin::Permission
  default_scope -> do
    where(namespace: "site_module", resource_name: "gobierto_budgets")
  end
end
