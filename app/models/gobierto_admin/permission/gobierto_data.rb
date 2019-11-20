# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoData < GroupPermission
    default_scope -> { for_class_module }
  end
end
