# frozen_string_literal: true

module Integration
  module AdminGroupsConcern
    extend ActiveSupport::Concern

    included do
      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:steve)
      end

      def allow_regular_admin_manage_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_manage_plans_group)
      end

      def allow_regular_admin_edit_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_edit_plans_group)
      end

      def allow_regular_admin_moderate_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_moderate_plans_group)
      end
    end
  end
end
