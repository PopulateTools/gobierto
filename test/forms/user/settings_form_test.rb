require "test_helper"

class User::SettingsFormTest < ActiveSupport::TestCase
  def valid_user_settings_form
    @valid_user_settings_form ||= User::SettingsForm.new(
      user_id: user.id,
      name: 'Fulano',
      email: 'example@example.org',
      date_of_birth_day: 1,
      date_of_birth_month: 1,
      date_of_birth_year: 1982,
      gender: User.genders[:male],
      custom_records: {
        madrid_custom_user_field_district.name => { "custom_user_field_id" => madrid_custom_user_field_district.id, "value" => madrid_custom_user_field_district.options.keys.first },
        madrid_custom_user_field_association.name => { "custom_user_field_id" => madrid_custom_user_field_association.id, "value" => "Foo" }
      }
    )
  end

  def madrid_custom_user_field_district
    madrid_custom_user_field_district ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_district)
  end

  def madrid_custom_user_field_association
    madrid_custom_user_field_association ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_association)
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
