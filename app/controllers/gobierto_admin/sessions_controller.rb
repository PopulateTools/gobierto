module GobiertoAdmin
  class SessionsController < BaseController
    skip_before_action :authenticate_admin!, only: [:new, :create, :destroy]
    before_action :require_no_authentication, only: [:new, :create]

    layout "gobierto_admin/layouts/sessions"

    def new; end

    def create
      admin = Admin.active.find_by(email: session_params[:email].downcase)

      if admin.try(:authenticate, session_params[:password])
        admin.update_session_data(remote_ip)
        sign_in_admin(admin.id)
        redirect_to after_sign_in_path, notice: t(".success")
      else
        flash.now[:alert] = t(".error")
        render :new
      end
    end

    def destroy
      sign_out_admin
      leave_site
      redirect_to after_sign_out_path, notice: t(".success")
    end

    private

    def session_params
      params.require(:session).permit(:email, :password)
    end
  end
end
