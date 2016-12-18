require "test_helper"

class User::SubscriptionTest < ActiveSupport::TestCase
  def user_subscription
    @user_subscription ||= user_subscriptions(:dennis_consultation_madrid_open)
  end

  def test_valid
    assert user_subscription.valid?
  end
end
