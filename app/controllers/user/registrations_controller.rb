class User::RegistrationsController < User::BaseController
  before_action :require_no_authentication

  def new
    @user_registration_form = User::RegistrationForm.new
  end

  def create
    @user_registration_form = User::RegistrationForm.new(
      user_registration_params.merge(site: current_site, creation_ip: remote_ip)
    )

    if @user_registration_form.save
      redirect_to root_path, notice: "Please check your inbox for confirmation."
    else
      flash.now[:alert] = "The data you entered doesn't seem to be valid. Please try again."
      render :new
    end
  end

  private

  def user_registration_params
    params.require(:user_registration).permit(
      :email,
      :name,
      :password,
      :password_confirmation
    )
  end
end
