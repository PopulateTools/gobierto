module GobiertoAdmin
  class Permission::GobiertoAttachments < Permission
    default_scope -> do
      where(namespace: "site_module", resource_name: "gobierto_attachments")
    end
  end
end
