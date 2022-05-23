# frozen_string_literal: true

require "test_helper"

class User::SubscriptionIndexTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = user_subscriptions_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def test_subscription_management
    skip "User subscriptions disabled"

    element_names = ["user_subscription_preferences_modules_gobierto_people",
                     "user_subscription_preferences_gobierto_people_people_#{person.id}"]
    with_signed_in_user(user) do
      visit @path

      assert has_content?("Your alerts")
      assert has_checked_field?("user_subscription_preferences_notification_frequency_hourly")

      check "People"
      check person.name

      click_button "Save"

      assert has_message?("Preferences updated successfully")

      element_names.each do |el|
        element = page.find("##{el}", visible: false)
        assert element.checked?
      end
    end
  end

  def test_broader_subscription_disables_specific_subscriptions
    skip "User subscriptions disabled"

    with_javascript do
      with_signed_in_user(user) do
        visit @path

        site_element = page.find("#user_subscription_preferences_site_to_subscribe", visible: false)
        module_element = page.find("#user_subscription_preferences_modules_gobierto_people", visible: false)
        person_element = page.find("#user_subscription_preferences_gobierto_people_people_#{person.id}", visible: false)

        refute module_element.checked?
        refute module_element.disabled?
        refute person_element.checked?
        refute person_element.disabled?

        site_element.execute_script("this.click()")

        assert module_element.checked?
        assert module_element.disabled?
        assert person_element.checked?
        assert person_element.disabled?

        site_element.execute_script("this.click()")
        module_element.execute_script("this.click()")

        refute module_element.disabled?
        assert person_element.checked?
        assert person_element.disabled?

      end
    end
  end

  def test_site_subscription
    skip "User subscriptions disabled"

    element_names = ["user_subscription_preferences_modules_gobierto_people",
                     "user_subscription_preferences_gobierto_people_people_#{person.id}"]
    with_javascript do
      with_signed_in_user(user) do
        visit @path

        page.find("#user_subscription_preferences_site_to_subscribe", visible: false).execute_script("this.click()")

        element_names.each do |el|
          element = page.find("##{el}", visible: false)
          assert element.checked?
          assert element.disabled?
        end

        click_button "Save"

        assert has_content?("Preferences updated successfully")

        element_names.each do |el|
          element = page.find("##{el}", visible: false)
          assert element.checked?
          assert element.disabled?
        end
      end
    end
  end
end
