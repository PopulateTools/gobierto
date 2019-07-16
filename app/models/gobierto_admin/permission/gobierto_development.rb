# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoDevelopment < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_type: "gobierto_development") }
  end
end
