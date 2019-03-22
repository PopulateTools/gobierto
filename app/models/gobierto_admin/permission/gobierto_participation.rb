# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoParticipation < GroupPermission
    default_scope -> { where(namespace: "site_module", resource_name: "gobierto_participation") }
  end
end
