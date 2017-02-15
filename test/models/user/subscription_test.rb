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
    @person_event ||= gobierto_people_person_events(:richard_published)
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

  def test_find_subscriptions_when_subscribed_to_module
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople"
    User::Subscription.create! user: other_user, site: site, subscribable_type: "GobiertoBudgetConsultations"

    [
      ["GobiertoPeople::PersonEvent", person_event.id],
      ["GobiertoPeople::PersonEvent", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil]
    ].each do |subject|
      subject_type, subject_id = subject
      assert_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), user.id
      assert_not_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), other_user.id
    end
  end

  def test_find_subscriptions_when_subscribed_to_class
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person"
    User::Subscription.create! user: other_user, site: site, subscribable_type: "GobiertoPeople"

    [
      ["GobiertoPeople::PersonEvent", person_event.id],
      ["GobiertoPeople::PersonEvent", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
    ].each do |subject|
      subject_type, subject_id = subject
      assert_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), user.id
      assert_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), other_user.id
    end
  end

  def test_find_subscriptions_when_subscribed_to_class_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person", subscribable_id: person.id

    [
      ["GobiertoPeople::PersonEvent", person_event.id],
      ["GobiertoPeople::PersonEvent", nil],
      ["GobiertoPeople::Person", person.id],
    ].each do |subject|
      subject_type, subject_id = subject
      assert_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), user.id
    end
  end

  def test_find_subscriptions_when_subscribed_to_subclass
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::PersonEvent"

    [
      ["GobiertoPeople::PersonEvent", person_event.id],
      ["GobiertoPeople::PersonEvent", nil],
    ].each do |subject|
      subject_type, subject_id = subject
      assert_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), user.id
    end
  end

  def test_find_subscriptions_when_subscribed_to_subclass_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::PersonEvent", subscribable_id: person_event.id

    [
      ["GobiertoPeople::PersonEvent", person_event.id],
    ].each do |subject|
      subject_type, subject_id = subject
      assert_includes User::Subscription.find_users_for(subject_type, subject_id, site.id), user.id
    end
  end
end
