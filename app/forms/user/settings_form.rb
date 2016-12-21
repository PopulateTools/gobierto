class User::SettingsForm
  include ActiveModel::Model

  attr_accessor(
    :user_id,
    :notification_frequency
  )

  def save
    save_user_settings if valid?
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def notification_frequency
    @notification_frequency ||= user.notification_frequency
  end

  private

  def save_user_settings
    @user = user.tap do |user_attributes|
      user_attributes.notification_frequency = notification_frequency
    end

    if @user.valid?
      @user.save

      @user
    else
      false
    end
  end
end
