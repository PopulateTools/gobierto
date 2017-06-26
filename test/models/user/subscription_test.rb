require "test_helper"

class User::SubscriptionTest < ActiveSupport::TestCase
  def user_subscription
    @user_subscription ||= user_subscriptions(:dennis_consultation_madrid_open)
  end

  def user
    @user ||= users(:dennis)
  end

  def other_user
    @other_user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def person_event
    @person_event ||= gobierto_calendars_events(:richard_published)
  end

  def generic_user_subscription
    @generic_user_subscription ||= user_subscriptions(:dennis_consultations)
  end

  def test_valid
    assert user_subscription.valid?
  end

  def test_specific?
    assert user_subscription.specific?
    refute generic_user_subscription.specific?
  end

  def test_generic?
    assert generic_user_subscription.generic?
    refute user_subscription.generic?
  end

  def test_subscribable
    refute_equal GobiertoBudgetConsultations::Consultation, user_subscription.subscribable
    assert user_subscription.subscribable.is_a?(GobiertoBudgetConsultations::Consultation)

    assert_equal GobiertoBudgetConsultations::Consultation, generic_user_subscription.subscribable
  end
end
