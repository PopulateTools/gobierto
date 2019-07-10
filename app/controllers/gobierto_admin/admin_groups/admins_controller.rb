# frozen_string_literal: true

module GobiertoAdmin
  module AdminGroups
    class AdminsController < BaseController
      before_action :allow_admin
      layout false

      def index
        @admins = admin_group.admins

        render(:index, layout: false) && return if request.xhr?
      end

      private

      def admin_group
        @admin_group = current_site.admin_groups.system.find(params[:admin_group_id])
      end

      def moderation_policy
        @moderation_policy ||= GobiertoAdmin::ModerationPolicy.new(current_admin: current_admin, current_site: current_site, moderable: admin_group.resource)
      end

      def allow_admin
        redirect_to admin_users_path and return false unless moderation_policy.manage? || admin_group.admins.where(id: current_admin.id).exists?
      end

    end
  end
end
