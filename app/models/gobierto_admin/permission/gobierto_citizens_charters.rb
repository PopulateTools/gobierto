# frozen_string_literal: true

module GobiertoAdmin
  class Permission::GobiertoCitizensCharters < Permission
    default_scope -> { for_class_module }
  end
end
