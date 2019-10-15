# frozen_string_literal: true

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

  def auth_strategy_site
    @auth_strategy_site ||= sites(:cortegada)
  end

  def auth_strategy_site_user
    @auth_strategy_site_user ||= users(:martin).tap do |user|
      user.update(confirmation_token: nil)
    end
  end

  def test_settings_page
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

  def test_settings_page_with_password_disabled
    with_current_site(auth_strategy_site) do

      with_current_user(auth_strategy_site_user) do
        visit @path

        assert has_no_field? :user_confirmation_password
        assert has_no_field? :user_confirmation_password_confirmation

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

  def test_settings_page_with_read_only_attributes
    auth_strategy_site.configuration.stubs(:auth_modules_data).returns(
      [OpenStruct.new(
        name: "null_strategy",
        read_only_user_attributes: %w(name gender date_of_birth)
      )]
    )

    with(site: auth_strategy_site) do
      with_current_user(auth_strategy_site_user) do
        visit @path

        assert has_field?("user_settings_name", disabled: true)
        assert has_field?("user_settings_date_of_birth_1i", disabled: true)
        assert has_field?("user_settings_date_of_birth_2i", disabled: true)
        assert has_field?("user_settings_date_of_birth_3i", disabled: true)
        assert has_field?("user_settings_gender_male", disabled: true)
        assert has_field?("user_settings_gender_female", disabled: true)

        click_on "Save"
        assert has_message?("Settings saved successfully")
        assert has_field?("user_settings_name", disabled: true, with: auth_strategy_site_user.name)
      end
    end
  end

  def test_settings_page_update_custom_fields
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
