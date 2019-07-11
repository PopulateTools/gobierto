# frozen_string_literal: true

module GobiertoAdmin
  module AdminGroups
    class AdminsController < BaseController
      before_action :allow_admin
      layout false

      def index
        set_members

        render(:index, layout: false) && return if request.xhr?
      end

      def destroy
        admin_group.admins.delete(admin) unless admin == owner

        set_members

        respond_to do |format|
          format.js
        end
      end

      def create
        if params.has_key? :admin_group
          create_admins_params[:admin_ids].each do |admin_id|
            admin = GobiertoAdmin::Admin.find_by(id: admin_id)
            next unless admin.present? && !admin_group.admins.where(id: admin_id).exists?

            admin_group.admins << admin
          end
        end

        set_members
        respond_to do |format|
          format.js
        end
      end

      private

      def admin
        @admin ||= admin_group.admins.find(params[:id])
      end

      def create_admins_params
        params.require(:admin_group).permit(admin_ids: [])
      end

      def set_members
        @members = admin_group.admins.order(created_at: :desc)
        @available_not_members = current_site.admins.where.not(id: admin_group.admins)
        owner
      end

      def owner
        @owner ||= admin_group.resource.try(:owner)
      end

      def admin_group
        @admin_group ||= current_site.admin_groups.system.find(params[:admin_group_id])
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
