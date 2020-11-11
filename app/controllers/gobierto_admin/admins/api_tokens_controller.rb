# frozen_string_literal: true

module GobiertoAdmin
  module Admins
    class ApiTokensController < BaseController
      include ::GobiertoCommon::ApiTokensConcern

      before_action :check_permissions!

      private

      def check_permissions!
        redirect_to admin_users_path and return false unless current_admin.managing_user? || owner == current_admin
      end

      def owner_path
        owner == current_admin ? edit_admin_admin_settings_path : edit_admin_admin_path(owner)
      end

      def owner_type
        :admin
      end

      def owner
        @owner ||= GobiertoAdmin::Admin.find(params[:admin_id])
      end
    end
  end
end
