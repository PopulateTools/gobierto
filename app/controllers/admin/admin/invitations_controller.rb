class Admin::Admin::InvitationsController < Admin::BaseController
  def new
    @admin_invitation_form = Admin::AdminInvitationForm.new
    @sites = get_sites
  end

  def create
    @admin_invitation_form = Admin::AdminInvitationForm.new(
      admin_invitation_params.merge(admin_id: current_admin.id)
    )
    @sites = get_sites

    if @admin_invitation_form.process
      flash[:notice] = "The invitations have been successfully sent."
    else
      flash[:notice] = "There was a problem sending the invitations."
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
