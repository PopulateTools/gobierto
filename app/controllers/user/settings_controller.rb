class User::SettingsController < User::BaseController
  before_action :authenticate_user!

  def show
    @user_settings_form = User::SettingsForm.new({
      user_id: current_user.id, name: current_user.name,
      email: current_user.email,
      year_of_birth: current_user.year_of_birth, gender: current_user.gender
    })
    @user_genders = get_user_genders
    @user_years_of_birth = get_user_years_of_birth
  end

  def update
    @user_settings_form = User::SettingsForm.new(user_id: current_user.id)
    @user_settings_form.assign_attributes(user_settings_params)

    if @user_settings_form.save
      flash[:notice] = t(".success")
      redirect_to user_settings_path
    else
      @user_genders = get_user_genders
      @user_years_of_birth = get_user_years_of_birth
      flash[:alert] = t(".error")
      render 'show'
    end
  end

  private

  def user_settings_params
    permitted_params = [:name, :password, :password_confirmation, :year_of_birth, :gender]
    if params[:user_settings] && params[:user_settings][:custom_records]
      permitted_params << {custom_records: Hash[params[:user_settings][:custom_records].keys.map{ |k| [k, [:custom_user_field_id, :value]] }]}
    end

    params.require(:user_settings).permit(permitted_params)
  end

  def get_user_genders
    User.genders
  end

  def get_user_years_of_birth
    (100.years.ago.year..10.years.ago.year).to_a.reverse
  end
end
