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

  def test_settings_page
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path

        fill_in :user_settings_name, with: "New name"
        select "1992", from: :user_settings_date_of_birth_1i
        select "January", from: :user_settings_date_of_birth_2i
        select "1", from: :user_settings_date_of_birth_3i
        choose "Male"

        click_on "Save"
        assert has_message?("Settings saved successfully")
      end
    end
  end

  def test_settings_page_update_custom_fields
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path
        assert has_select?("Districts", selected: "Center")

        fill_in :user_settings_name, with: "New name"
        select "1992", from: :user_settings_date_of_birth_1i
        select "January", from: :user_settings_date_of_birth_2i
        select "1", from: :user_settings_date_of_birth_3i
        choose "Male"
        select "Chamberi", from: "Districts"

        click_on "Save"
        assert has_message?("Settings saved successfully")

        assert has_select?("Districts", selected: "Chamberi")
      end
    end
  end
end
