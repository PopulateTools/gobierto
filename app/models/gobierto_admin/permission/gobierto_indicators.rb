# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoIndicators < Permission
    default_scope -> do
      where(namespace: 'site_module', resource_name: 'gobierto_indicators')
    end
  end
end
