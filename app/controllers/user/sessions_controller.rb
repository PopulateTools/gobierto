# frozen_string_literal: true

class User::SessionsController < User::BaseController
  before_action :authenticate_user!, only: [:destroy]
  before_action :require_no_authentication, only: %i[new create]

  layout 'user/layouts/sessions'

  def new
    @user_session_form = User::SessionForm.new(referrer_url: request.referer)
    @user_registration_form = User::RegistrationForm.new(referrer_url: request.referer, referrer_entity: referrer_entity)
    @user_password_form = User::NewPasswordForm.new
  end

  def create
    @user_session_form = User::SessionForm.new(user_session_params)

    if @user_session_form.save
      user = @user_session_form.user

      user.update_session_data(remote_ip)
      sign_in_user(user.id)

      redirect_to(
        after_sign_in_path(@user_session_form.referrer_url),
        notice: t('.success')
      )
    else
      @user_registration_form = User::RegistrationForm.new
      @user_password_form = User::NewPasswordForm.new

      flash.now[:alert] = t('.error')
      render :new
    end
  end

  def destroy
    sign_out_user
    redirect_to after_sign_out_path, notice: t('.success')
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password, :referrer_url)
  end

  def referrer_entity
    if request.referer.present?
      if request.referer.include?('consultas-presupuestos')
        'GobiertoBudgetConsultations::Consultation'
      end
    end
  end
end
