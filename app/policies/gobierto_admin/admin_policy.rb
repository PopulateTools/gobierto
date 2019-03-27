# frozen_string_literal: true

module GobiertoAdmin
  class AdminPolicy
    attr_reader :admin_user, :admin

    def initialize(admin_user, admin = nil)
      @admin_user = admin_user
      @admin = admin
    end

    def update?
      return true unless admin.present?

      god_or_manager_skipping_god
    end

    def manage_permissions?
      return true unless admin.present?

      god_or_manager_skipping_god
    end

    def manage_sites?
      return true unless admin.present?

      god_or_manager && !admin.god? && admin.regular?
    end

    def manage_authorization_levels?
      return true unless admin.present?

      god_or_manager_skipping_god
    end

    private

    def god_or_manager
      admin_user.god? || admin_user.manager?
    end

    def god_or_manager_skipping_god
      admin_user.god? || (admin_user.manager? && !admin.god?)
    end
  end
end
