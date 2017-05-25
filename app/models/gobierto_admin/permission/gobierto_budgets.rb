# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoBudgets < Permission
    default_scope -> do
      where(namespace: 'site_module', resource_name: 'gobierto_budgets')
    end
  end
end
