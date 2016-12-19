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

  def test_subscription_index
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path

        within ".user-subscription-list" do
          user.subscriptions.each do |user_subscription|
            assert has_selector?(
              "tr#user-subscription-item-#{user_subscription.id}",
              text: user_subscription.subscribable_label
            )
          end
        end
      end
    end
  end
end
