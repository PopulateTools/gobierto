# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoDevelopment < Permission
    default_scope -> do
      where(namespace: 'site_module', resource_name: 'gobierto_development')
    end
  end
end
