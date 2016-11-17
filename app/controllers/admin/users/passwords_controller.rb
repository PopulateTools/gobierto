class Admin::Users::PasswordsController < Admin::BaseController
  def new
    @user = find_user
    @user_password_form = Admin::UserPasswordForm.new
  end

  def create
    @user = find_user
    @user_password_form = Admin::UserPasswordForm.new(
      user_password_params.merge(id: params[:user_id])
    )

    if @user_password_form.save
      redirect_to edit_admin_user_path(@user), notice: "User password was successfully updated."
    else
      render :new
    end
  end

  private

  def find_user
    User.find(params[:user_id])
  end

  def user_password_params
    params.require(:user_password).permit(
      :password,
      :password_confirmation
    )
  end
end
