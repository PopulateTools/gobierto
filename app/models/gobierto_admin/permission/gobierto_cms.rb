module GobiertoAdmin
  class Permission::GobiertoCms < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_cms")
    end
  end
end
