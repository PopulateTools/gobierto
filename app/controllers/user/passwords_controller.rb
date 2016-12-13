class User::PasswordsController < User::BaseController
  before_action :require_no_authentication

  def new
    @user_password_form = User::NewPasswordForm.new
  end

  def create
    @user_password_form = User::NewPasswordForm.new(
      user_new_password_params.merge(site: current_site)
    )

    if @user_password_form.save
      flash.now[:notice] = "Please check your inbox to get instructions."
    else
      flash.now[:alert] = "The email address specified doesn't seem to be valid."
    end

    render :new
  end

  def edit
    user = User.find_by_reset_password_token(params[:reset_password_token])

    if user
      @user_password_form = User::EditPasswordForm.new(user_id: user.id)
    else
      flash.now[:alert] = "This URL doesn't seem to be valid."
      redirect_to user_root_path
    end
  end

  def update
    @user_password_form = User::EditPasswordForm.new(
      user_edit_password_params
    )

    if @user_password_form.save
      user = @user_password_form.user

      user.recovered!
      user.update_session_data(remote_ip)
      sign_in_user(user.id)

      redirect_to(after_sign_in_path, notice: "Signed in successfully.")
    else
      flash[:notice] = "There was a problem changing your password."
      render :edit
    end
  end

  private

  def user_new_password_params
    params.require(:user_password).permit(
      :email
    )
  end

  def user_edit_password_params
    params.require(:user_password).permit(
      :user_id,
      :password,
      :password_confirmation
    )
  end
end
