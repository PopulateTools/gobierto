# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoCms < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_name: "gobierto_cms") }
  end
end
