# frozen_string_literal: true

class User::PasswordsController < User::BaseController
  before_action :require_no_authentication

  layout "user/layouts/sessions"

  def create
    @user_password_form = User::NewPasswordForm.new(
      user_new_password_params.merge(site: current_site)
    )

    if @user_password_form.save
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".error")
    end

    redirect_to new_user_sessions_path
  end

  def edit
    user = current_site.users.confirmed.find_by_reset_password_token(params[:reset_password_token])

    if user
      @user_password_form = User::EditPasswordForm.new(user_id: user.id, site: current_site)
    else
      redirect_to new_user_sessions_path, alert: t(".error")
    end
  end

  def update
    @user_password_form = User::EditPasswordForm.new(
      user_edit_password_params.merge(site: current_site)
    )

    if @user_password_form.save
      user = @user_password_form.user

      user.recovered!
      user.update_session_data(remote_ip)
      sign_in_user(user.id)

      redirect_to after_sign_in_path, notice: t(".success")
    else
      flash.now[:notice] = t(".error")
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
