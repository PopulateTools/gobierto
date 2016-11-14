class Admin::Permission::GobiertoDevelopment < Admin::Permission
  default_scope -> do
    where(namespace: "site_module", resource_name: "gobierto_development")
  end
end
