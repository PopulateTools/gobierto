# frozen_string_literal: true

class User::RegistrationsController < User::BaseController

  before_action :require_no_authentication, :check_registration_enabled
  invisible_captcha honeypot: :ic_email, scope: :user_registration

  layout "user/layouts/sessions"

  def create
    @user_registration_form = User::RegistrationForm.new(
      user_registration_params.merge(site: current_site, creation_ip: remote_ip)
    )

    if @user_registration_form.save
      flash[:notice] = t(".success")
    elsif @user_registration_form.errors.added?(:email, "has already been taken")
      flash[:notice] = t(".email_taken")
    else
      flash[:alert] = t(".error")
    end

    redirect_to new_user_sessions_path
  end

  private

  def user_registration_params
    params.require(:user_registration).permit(:email, :referrer_url, :referrer_entity)
  end
end
