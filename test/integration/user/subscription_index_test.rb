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
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path

        assert has_content?("Your alerts")
        assert has_checked_field?("user_subscription_preferences_notification_frequency_hourly")

        check "People"
        check person.name

        click_button "Save"

        assert has_message?("Preferences updated successfully")

        assert has_checked_field?("user_subscription_preferences_modules_gobierto_people")
        assert has_checked_field?("user_subscription_preferences_gobierto_people_people_#{person.id}")
      end
    end
  end

  def test_site_subscription
    with_javascript do
      with_current_site(site) do
        with_signed_in_user(user) do
          visit @path

          page.find("#user_subscription_preferences_site_to_subscribe", visible: false).trigger("click")

          click_button "Save"

          assert has_content?("Preferences updated successfully")

          assert has_checked_field?("user_subscription_preferences_modules_gobierto_people", visible: false)
          assert has_checked_field?("user_subscription_preferences_modules_gobierto_budget_consultations", visible: false)
          assert has_checked_field?("user_subscription_preferences_gobierto_people_people_#{person.id}", visible: false)
        end
      end
    end
  end
end
