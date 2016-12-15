class User::ConfirmationRequestsController < User::BaseController
  before_action :require_no_authentication

  def create
    @user_confirmation_request_form = User::ConfirmationRequestForm.new(
      user_confirmation_request_params.merge(site: current_site)
    )

    if @user_confirmation_request_form.save
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".error")
    end

    redirect_to new_user_sessions_path
  end

  private

  def user_confirmation_request_params
    params.require(:user_confirmation_request).permit(:email)
  end
end
