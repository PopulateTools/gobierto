# frozen_string_literal: true

class User::CensusVerificationsController < User::BaseController
  before_action :authenticate_user!
  before_action(only: [:new, :create]) { require_not_verified_user_in(current_site) }

  def new
    @user_verification_form = census_verification_form_class.new(
      site_id: current_site.id, referrer_url: request.referrer,
      date_of_birth_year: current_user.date_of_birth.year,
      date_of_birth_month: current_user.date_of_birth.month,
      date_of_birth_day: current_user.date_of_birth.day
    )
    respond_to do |format|
      format.html
      format.js { render js: "window.location='/user/verifications/new'" }
    end
  end

  def create
    @user_verification_form = census_verification_form_class.new(
      user_verification_params.except(*ignored_user_verification_params).merge(
        date_of_birth_year: user_verification_params["date_of_birth(1i)"],
        date_of_birth_month: user_verification_params["date_of_birth(2i)"],
        date_of_birth_day: user_verification_params["date_of_birth(3i)"],
        user_id: current_user.id,
        creation_ip: remote_ip,
        site_id: current_site.id
      )
    )

    if @user_verification_form.save && @user_verification_form.user.census_verified?
      redirect_to(
        @user_verification_form.referrer_url.present? ? @user_verification_form.referrer_url : user_settings_path,
        notice: t(".notice")
      )
    else
      flash.now[:alert] = t(".error")
      render :new
    end
  end

  private

  def user_verification_params
    params.require(:user_verification).permit(:document_number, :date_of_birth, :site_id, :referrer_url)
  end

  def ignored_user_verification_params
    ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"]
  end

  def census_verification_form_class
    @census_verification_form_class ||= custom_census_verification_form_class.presence || User::CensusVerificationForm
  end

  def custom_census_verification_form_class
    return unless auth_modules_present?

    if (name = current_site.configuration.auth_modules_data.map(&:census_verification_form).compact.first).present?
      User.const_get(name)
    end
  end
end
