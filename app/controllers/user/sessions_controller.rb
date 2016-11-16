class User::SessionsController < User::BaseController
  def new; end

  def create
    user = User.confirmed.find_by(email: session_params[:email].downcase)

    if user.try(:authenticate, session_params[:password])
      user.update_session_data(remote_ip)
      sign_in_user(user.id)
      redirect_to(after_sign_in_path, notice: "Signed in successfully.")
    else
      flash.now[:alert] = "The data you entered doesn't seem to be valid. Please try again."
      render :new
    end
  end

  def destroy
    sign_out_user
    redirect_to(after_sign_out_path, notice: "Signed out successfully.")
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
