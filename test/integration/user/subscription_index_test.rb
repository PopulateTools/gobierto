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
end
