module GobiertoAdmin
  class Permission::GobiertoObservatory < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_observatory")
    end
  end
end
