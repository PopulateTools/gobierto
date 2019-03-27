# frozen_string_literal: true

class User::SettingsController < User::BaseController
  before_action :authenticate_user!

  def show
    @user_settings_form = User::SettingsForm.new({
      user_id: current_user.id, name: current_user.name,
      email: current_user.email, gender: current_user.gender,
      date_of_birth_year: current_user.date_of_birth.year,
      date_of_birth_month: current_user.date_of_birth.month,
      date_of_birth_day: current_user.date_of_birth.day,
      password_enabled: password_enabled
    })
    @user_genders = get_user_genders
  end

  def update
    @user_settings_form = User::SettingsForm.new(user_id: current_user.id, password_enabled: password_enabled)
    @user_settings_form.assign_attributes(user_settings_params.except(*ignored_user_settings_params).merge(
      date_of_birth_year: user_settings_params["date_of_birth(1i)"],
      date_of_birth_month: user_settings_params["date_of_birth(2i)"],
      date_of_birth_day: user_settings_params["date_of_birth(3i)"],
    ))

    if @user_settings_form.save
      flash[:notice] = t(".success")
      redirect_to user_settings_path
    else
      @user_genders = get_user_genders
      flash[:alert] = t(".error")
      render "show"
    end
  end

  private

  def user_settings_params
    permitted_params = [:name, :password, :password_confirmation, :date_of_birth, :gender]
    if params[:user_settings] && params[:user_settings][:custom_records]
      permitted_params << { custom_records: Hash[params[:user_settings][:custom_records].keys.map { |k| [k, [:custom_user_field_id, :value]] }] }
    end

    params.require(:user_settings).permit(permitted_params)
  end

  def get_user_genders
    User.genders
  end

  def password_enabled
    @password_enabled ||= !auth_modules_present? || current_site.configuration.auth_modules_data.any? { |auth_module| auth_module.password_enabled }
  end

  def ignored_user_settings_params
    ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"]
  end

end
