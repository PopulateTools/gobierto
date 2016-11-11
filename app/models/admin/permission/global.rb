class Admin::Permission::Global < Admin::Permission
  default_scope -> do
    where(namespace: "global", resource_name: "global")
  end
end
