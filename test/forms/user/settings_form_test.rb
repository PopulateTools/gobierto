require "test_helper"

class User::SettingsFormTest < ActiveSupport::TestCase
  def valid_user_settings_form
    @valid_user_settings_form ||= User::SettingsForm.new(
      user_id: user.id,
      name: 'Fulano',
      email: 'example@example.org',
      year_of_birth: 1981,
      gender: User.genders[:male]
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
