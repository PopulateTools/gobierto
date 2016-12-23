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
        flash[:notice] = t(".success")
      else
        flash[:notice] = t(".error")
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
