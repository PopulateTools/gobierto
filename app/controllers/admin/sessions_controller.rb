class Admin::SessionsController < Admin::BaseController
  skip_before_action :authenticate_admin!

  def new; end

  def create
    admin = Admin.find_by(email: session_params[:email].downcase)

    if admin.try(:authenticate, session_params[:password])
      sign_in_admin(admin.id)
      redirect_to(after_sign_in_path, alert: "Signed in successfully.")
    else
      flash.now[:alert] = "The data you entered doesn't seem to be valid. Please try again."
      render :new
    end
  end

  def destroy
    sign_out_admin
    redirect_to(after_sign_out_path, alert: "Signed out successfully.")
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
