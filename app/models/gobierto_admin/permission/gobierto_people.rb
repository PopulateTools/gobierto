# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoPeople < Permission
    default_scope -> do
      where(namespace: 'site_module', resource_name: 'gobierto_people')
    end
  end
end
