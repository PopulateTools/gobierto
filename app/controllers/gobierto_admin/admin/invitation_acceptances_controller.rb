module GobiertoAdmin
  class Admin::InvitationAcceptancesController < BaseController
    skip_before_action :authenticate_admin!, raise: false
    before_action :require_no_authentication

    helper_method :site_from_domain

    layout "gobierto_admin/layouts/sessions"

    def show
      # TODO. Consider extracting this logic into a service object.
      #
      admin = Admin.find_by_invitation_token(params[:invitation_token])

      if admin
        admin.accept_invitation!
        admin.update_session_data(remote_ip)
        sign_in_admin(admin.id)
        track_accepted_activity

        redirect_to edit_admin_admin_settings_path, notice: t(".success")
      else
        redirect_to new_admin_sessions_path, notice: t(".error")
      end
    end

    private

    def track_accepted_activity
      Publishers::AdminActivity.broadcast_event("invitation_accepted", default_activity_params.merge({subject: current_admin}))
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin }
    end
  end
end
