module User::SubscriberTest
  def user_subscription
    @user_subscription ||= gobierto_budget_consultations_consultations(:madrid_open)
  end

  def user_subscription_site
    @user_subscription_site ||= sites(:madrid)
  end

  def test_subscribed_to?
    assert subscribed_user.subscribed_to?(user_subscription, user_subscription_site)
  end

  def test_subscribe_to!
    User::Subscription.delete_all

    assert subscribed_user.subscribe_to!(user_subscription, user_subscription_site)
  end

  def test_subscribe_to_when_already_subscribed
    assert subscribed_user.subscribe_to!(user_subscription, user_subscription_site)
  end

  def test_unsubscribe_from!
    assert subscribed_user.unsubscribe_from!(user_subscription, user_subscription_site)
  end

  def test_unsubscribe_from_when_not_subscribed
    User::Subscription.delete_all

    assert subscribed_user.unsubscribe_from!(user_subscription, user_subscription_site)
  end
end
