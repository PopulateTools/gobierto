module GobiertoAdmin
  class SessionsController < BaseController
    before_action :check_auth_modules, only: [:new]
    skip_before_action :authenticate_admin!, only: [:new, :create, :destroy]
    skip_before_action :set_admin_site, only: [:new, :destroy]
    before_action :require_no_authentication, only: [:new, :create]

    helper_method :site_from_domain

    layout "gobierto_admin/layouts/sessions"

    def new; end

    def create
      admin = Admin.with_password.active.find_by(email: session_params[:email].downcase)

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

    def check_auth_modules
      redirect_to auth_path(request.parameters) and return if controller_name == "sessions" && auth_modules_present?
    end
  end
end
