class User::RegistrationsController < User::BaseController
  before_action :require_no_authentication

  layout "user/layouts/sessions"

  def create
    @user_registration_form = User::RegistrationForm.new(
      user_registration_params.merge(site: current_site, creation_ip: remote_ip)
    )

    if @user_registration_form.save
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".error")
    end

    redirect_to new_user_sessions_path
  end

  private

  def user_registration_params
    params.require(:user_registration).permit(:email)
  end
end
