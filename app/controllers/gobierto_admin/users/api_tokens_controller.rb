# frozen_string_literal: true

module GobiertoAdmin
  module Users
    class ApiTokensController < BaseController
      include ::GobiertoCommon::ApiTokensConcern

      private

      def owner_type
        :user
      end

      def owner_path
        edit_admin_user_path(owner)
      end

      def owner
        @owner ||= User.find(params[:user_id])
      end
    end
  end
end
