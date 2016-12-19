require "test_helper"

class User::SubscriptionCancelTest < ActionDispatch::IntegrationTest
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

  def user_subscription
    @user_subscription ||= user.subscriptions.first
  end

  def test_subscription_cancel
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path

        within "tr#user-subscription-item-#{user_subscription.id}" do
          click_link "Cancel subscription"
        end

        assert has_message?("Subscription was successfully canceled")
      end
    end
  end
end
