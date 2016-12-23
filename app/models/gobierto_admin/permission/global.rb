module GobiertoAdmin
  class Permission::Global < Permission
    default_scope -> do
      where(namespace: "global", resource_name: "global")
    end
  end
end
