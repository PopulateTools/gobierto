# frozen_string_literal: true

module GobiertoAdmin
  class Users::PasswordsController < BaseController
    def new
      @user = find_user
      @user_password_form = UserPasswordForm.new
    end

    def create
      @user = find_user
      @user_password_form = UserPasswordForm.new(
        user_password_params.merge(id: params[:user_id])
      )

      if @user_password_form.save
        redirect_to edit_admin_user_path(@user), notice: t(".success")
      else
        flash.now[:alert] = t(".error")
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
end
