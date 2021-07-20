# frozen_string_literal: true

module User::SubscriberTest

  def subscription_subject
    @subscription_subject ||= gobierto_common_terms(:cat)
  end

  def subscription_site
    @subscription_site ||= sites(:madrid)
  end

  def user_without_subscriptions
    @user_without_subscriptions ||= users(:peter)
  end

  def user_other
    @user_other ||= users(:janet)
  end

  def test_subscribed_to?
    assert subscribed_user.subscribed_to?(subscription_subject, subscription_site)
  end

  def test_subscribe_to!
    refute user_without_subscriptions.subscribed_to?(subscription_subject, subscription_site)
    assert user_without_subscriptions.subscribe_to!(subscription_subject, subscription_site)
    assert user_without_subscriptions.subscribed_to?(subscription_subject, subscription_site)
  end

  def test_subscribe_to_when_already_subscribed
    assert subscribed_user.subscribe_to!(subscription_subject, subscription_site)
    assert subscribed_user.subscribed_to?(subscription_subject, subscription_site)
  end

  def test_unsubscribe_from!
    assert user_other.subscribe_to!(subscription_subject, subscription_site)
    assert user_other.unsubscribe_from!(subscription_subject, subscription_site)
    refute user_other.subscribed_to?(subscription_subject, subscription_site)
  end

  def test_unsubscribe_from_when_not_subscribed
    user_other.unsubscribe_from!(subscription_subject, subscription_site)
    assert_nil user_other.unsubscribe_from!(subscription_subject, subscription_site)
  end

  def test_toggle_subscription_when_already_subscribed
    subscribed_user.subscribe_to!(subscription_subject, subscription_site)
    assert_equal(
      [:delete, true],
      subscribed_user.toggle_subscription!(subscription_subject, subscription_site)
    )
  end

  def test_toggle_subscription_when_not_subscribed
    subscribed_user.unsubscribe_from!(subscription_subject, subscription_site)

    assert_equal(
      [:create, true],
      subscribed_user.toggle_subscription!(subscription_subject, subscription_site)
    )
  end
end
