class User::ConfirmationRequestsController < User::BaseController
  before_action :require_no_authentication

  def new
    @user_confirmation_request_form = User::ConfirmationRequestForm.new
  end

  def create
    @user_confirmation_request_form = User::ConfirmationRequestForm.new(
      user_confirmation_request_params.merge(site: current_site)
    )

    if @user_confirmation_request_form.save
      flash.now[:notice] = "Please check your inbox to get instructions."
    else
      flash.now[:alert] = "The email address specified doesn't seem to be valid."
    end

    render :new
  end

  private

  def user_confirmation_request_params
    params.require(:user_confirmation_request).permit(:email)
  end
end
