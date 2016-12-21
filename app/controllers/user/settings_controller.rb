class User::SettingsController < User::BaseController
  before_action :authenticate_user!

  def show
    @user_settings_form = User::SettingsForm.new(user_id: current_user.id)
    @user_notification_frequencies = get_user_notification_frequencies
  end

  def update
    @user_settings_form = User::SettingsForm.new(
      user_settings_params.merge(user_id: current_user.id)
    )

    if @user_settings_form.save
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".error")
    end

    redirect_to user_settings_path
  end

  private

  def user_settings_params
    params.require(:user_settings).permit(
      :notification_frequency
    )
  end

  def get_user_notification_frequencies
    User.notification_frequencies
  end
end
