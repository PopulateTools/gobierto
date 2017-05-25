# frozen_string_literal: true

module GobiertoAdmin
  class Permission::Global < Permission
    default_scope -> do
      where(namespace: 'global', resource_name: 'global')
    end
  end
end
