# frozen_string_literal: true

require "test_helper"

class User::SubscriptionTest < ActiveSupport::TestCase

  def generic_subscription
    @generic_subscription ||= user_subscriptions(:reed_subscription_generic_site_updated)
  end

  def specific_subscription
    @specific_subscription ||= user_subscriptions(:dennis_subscription_specific_term_updated)
  end

  def user_generic_subscription
    @user_generic_subscription ||= users(:reed)
  end

  def user_specific_subscription
    @user_specific_subscription ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def term
    @term ||= gobierto_common_term(:cat)
  end

  def test_valid
    assert generic_subscription.valid?
    assert specific_subscription.valid?
  end

  def test_specific
    refute generic_subscription.specific?
    assert specific_subscription.specific?
  end

  def test_generic
    assert generic_subscription.generic?
    refute specific_subscription.generic?
  end

  def test_subscribable
    refute_equal GobiertoCommon::Term,      generic_subscription.subscribable
    assert_equal Subscribers::SiteActivity, generic_subscription.subscribable

    assert_equal "GobiertoCommon::Term",    specific_subscription.subscribable_type
    refute_equal Subscribers::SiteActivity, specific_subscription.subscribable
  end

end
