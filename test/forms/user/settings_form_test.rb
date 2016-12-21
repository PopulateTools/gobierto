require "test_helper"

class User::SettingsFormTest < ActiveSupport::TestCase
  def valid_user_settings_form
    @valid_user_settings_form ||= User::SettingsForm.new(
      user_id: user.id,
      notification_frequency: User.notification_frequencies["immediate"]
    )
  end

  def user
    @user ||= users(:reed)
  end

  def test_validation
    assert valid_user_settings_form.valid?
  end

  def test_save
    assert valid_user_settings_form.save
  end
end
