module GobiertoAdmin
  class Admin::InvitationsController < BaseController
    before_action :managing_user

    def new
      @admin_invitation_form = AdminInvitationForm.new(default_invitation_attributes)
      @sites = available_sites
    end

    def create
      @admin_invitation_form = AdminInvitationForm.new(restricted_invitation_params)
      @sites = available_sites

      if @admin_invitation_form.process
        if @admin_invitation_form.not_delivered_email_addresses.any?
          flash.now[:alert] = t(
            ".success_with_errors",
            email_addresses: @admin_invitation_form.not_delivered_email_addresses.to_sentence
          )
        else
          track_create_activity
          flash.now[:notice] = t(".success")
        end
      else
        flash.now[:alert] = t(".error")
      end

      render :new
    end

    private

    def admin_invitation_params
      params.require(:admin_invitation).permit(
        :emails,
        site_ids: []
      )
    end

    def restricted_invitation_params
      return admin_invitation_params if current_admin.managing_user?

      current_admin_site_ids = current_admin.admin_sites.pluck(:site_id).map(&:to_s)
      submitted_site_ids = Array(admin_invitation_params[:site_ids]).map(&:to_s)
      admin_invitation_params.merge(
        site_ids: submitted_site_ids.select { |id| current_admin_site_ids.include?(id) }
      )
    end

    def available_sites
      @available_sites ||= if current_admin.managing_user?
                             Site.select(:id, :domain).all
                           else
                             current_admin.sites.select(:id, :domain)
                           end
    end

    def default_invitation_attributes
      return {} unless available_sites.one?

      { site_ids: available_sites.pluck(:id) }
    end

    def track_create_activity
      Publishers::AdminActivity.broadcast_event("invitation_created", default_activity_params)
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin }
    end

    def managing_user
      redirect_to admin_users_path and return false unless current_admin.can_manage_admins?
    end
  end
end
