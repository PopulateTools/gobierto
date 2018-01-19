class User::ConfirmationsController < User::BaseController
  before_action :require_no_authentication

  layout "user/layouts/sessions"

  def new
    @user_confirmation_form = User::ConfirmationForm.new(
      confirmation_token: params[:confirmation_token],
      creation_ip: remote_ip,
      site: current_site,
      password_enabled: password_enabled
    )

    @user_genders = get_user_genders
    unless @user_confirmation_form.user
      redirect_to root_path, alert: t(".error")
    end
  end

  def create
    @user_confirmation_form = User::ConfirmationForm.new(
      user_confirmation_params.except(*ignored_user_confirmation_params).merge(
        date_of_birth_year: user_confirmation_params["date_of_birth(1i)"],
        date_of_birth_month: user_confirmation_params["date_of_birth(2i)"],
        date_of_birth_day: user_confirmation_params["date_of_birth(3i)"],
        creation_ip: remote_ip,
        site: current_site,
        password_enabled: password_enabled
      )
    )

    if @user_confirmation_form.save
      user = @user_confirmation_form.user

      user.update_session_data(remote_ip)
      sign_in_user(user.id)

      redirect_to after_sign_in_path(user.referrer_url), notice: t(".success")
    else
      @user_genders = get_user_genders

      flash.now[:alert] = t(".error")
      render :new
    end
  end

  private

  def user_confirmation_params
    permitted_params = [:confirmation_token, :name, :password, :password_confirmation, :date_of_birth, :gender, :document_number]
    if params[:user_confirmation] && params[:user_confirmation][:custom_records]
      permitted_params << {custom_records: Hash[params[:user_confirmation][:custom_records].keys.map{ |k| [k, [:custom_user_field_id, :value]] }]}
    end

    params.require(:user_confirmation).permit(permitted_params)
  end

  def get_user_genders
    User.genders
  end

  def password_enabled
    @password_enabled ||= !auth_modules_present? || current_site.configuration.auth_modules_data.any? { |auth_module| auth_module.password_enabled }
  end

  def ignored_user_confirmation_params
    ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"]
  end
end
