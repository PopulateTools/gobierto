class User::ConfirmationsController < User::BaseController
  def new
    @user_confirmation_form = User::ConfirmationForm.new
  end

  def create
    @user_confirmation_form = User::ConfirmationForm.new(
      user_confirmation_params.merge(site: current_site)
    )

    if @user_confirmation_form.save
      flash.now[:notice] = "Please check your inbox to get instructions."
    else
      flash.now[:alert] = "The email address specified doesn't seem to be valid."
    end

    render :new
  end

  def show
    # TODO. Consider extracting this logic into a service object.
    #
    user = User.find_by(confirmation_token: params[:confirmation_token])

    if user
      user.confirm!
      user.update_session_data(remote_ip)
      deliver_welcome_email
      sign_in_user(user.id)

      redirect_to(after_sign_in_path, notice: "Signed in successfully.")
    else
      flash.now[:alert] = "This URL doesn't seem to be valid."
      redirect_to root_path
    end
  end

  private

  def user_confirmation_params
    params.require(:user_confirmation).permit(:email)
  end

  def deliver_welcome_email
    User::UserMailer.welcome(user, current_site).deliver_later
  end
end
