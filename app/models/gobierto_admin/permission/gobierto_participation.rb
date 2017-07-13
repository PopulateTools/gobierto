module GobiertoAdmin
  class Permission::GobiertoParticipation < Permission
    default_scope -> do
      where(namespace: 'site_module', resource_name: 'gobierto_participation')
    end
  end
end
