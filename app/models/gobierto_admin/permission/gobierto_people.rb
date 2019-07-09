# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoPeople < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_type: "gobierto_people") }
  end
end
