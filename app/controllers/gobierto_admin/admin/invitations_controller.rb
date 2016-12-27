module GobiertoAdmin
  class Admin::InvitationsController < BaseController
    def new
      @admin_invitation_form = AdminInvitationForm.new
      @sites = get_sites
    end

    def create
      @admin_invitation_form = AdminInvitationForm.new(admin_invitation_params)
      @sites = get_sites

      if @admin_invitation_form.process
        if @admin_invitation_form.not_delivered_email_addresses.any?
          flash.now[:alert] = t(
            ".success_with_errors",
            email_addresses: @admin_invitation_form.not_delivered_email_addresses.to_sentence
          )
        else
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

    def get_sites
      Site.select(:id, :domain).all
    end
  end
end
