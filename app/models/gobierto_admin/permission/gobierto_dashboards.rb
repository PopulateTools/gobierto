# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoDashboards < GroupPermission
    default_scope -> { for_class_module }
  end
end
