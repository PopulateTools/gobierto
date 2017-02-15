require "test_helper"

class User::SettingsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = user_settings_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_notification_index
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path

        fill_in :user_settings_name, with: "New name"
        select 20.years.ago.year, from: :user_settings_year_of_birth
        choose "Male"

        click_on "Save"
        assert has_message?("Settings saved successfully")
      end
    end
  end
end
