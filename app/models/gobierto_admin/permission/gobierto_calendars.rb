module GobiertoAdmin
  class Permission::GobiertoCalendars < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_calendars")
    end
  end
end
