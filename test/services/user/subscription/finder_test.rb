# frozen_string_literal: true

require "test_helper"

class User::Subscription::FinderTest < ActiveSupport::TestCase
  def user_subscription
    @user_subscription ||= user_subscriptions(:dennis_subscription_specific_term_updated)
  end

  def subject
    User::Subscription::Finder
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

  def test_user_subscribed_to_when_subscribed_to_site
    User::Subscription.create! user: user, site: site, subscribable: site

    [
      ["GobiertoCalendars::Event", person_event.id],
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_user_subscribed_to_when_subscribed_to_module
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople"

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end

    [
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_user_subscribed_to_when_subscribed_to_class
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person"

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end

    [
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_user_subscribed_to_when_subscribed_to_class_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person", subscribable_id: person.id

    [
      ["GobiertoPeople::Person", person.id]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end

    [
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_user_subscribed_to_when_subscribed_to_subclass
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoCalendars::Event"

    [
      ["GobiertoCalendars::Event", person_event.id],
      ["GobiertoCalendars::Event", nil]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_user_subscribed_to_when_subscribed_to_subclass_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoCalendars::Event", subscribable_id: person_event.id

    [
      ["GobiertoCalendars::Event", person_event.id]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end

    [
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_to?(user, subscribable_type, subscribable_id, site.id)
      refute subject.user_subscribed_to?(other_user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscribed_to_by_broader_subscription_when_subscribed_to_site
    User::Subscription.create! user: user, site: site, subscribable: site

    [
      ["GobiertoCalendars::Event", person_event.id],
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscribed_to_by_broader_subscription_when_subscribed_to_module
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople"

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
    [
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscribed_to_by_broader_subscription_when_subscribed_to_class
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person"
    [
      ["GobiertoPeople::Person", person.id]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
    [
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscribed_to_by_broader_subscription_when_subscribed_to_sublcass
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoCalendars::Event"

    [
      ["GobiertoCalendars::Event", person_event.id]
    ].each do |subscribable_type, subscribable_id|
      assert subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
    [
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscribed_to_by_broader_subscription_when_subscribed_to_class_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person", subscribable_id: person.id

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscribed_to_by_broader_subscription_when_subscribed_to_subclass_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoCalendars::Event", subscribable_id: person_event.id

    [
      ["GobiertoCalendars::Event", person_event.id],
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute subject.user_subscribed_by_broader_subscription_to?(user, subscribable_type, subscribable_id, site.id)
    end
  end

  def test_subscriptions_for_when_subscribed_to_site
    User::Subscription.create! user: user, site: site, subscribable: site

    [
      ["GobiertoCalendars::Event", person_event.id],
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      assert_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end
  end

  def test_subscriptions_for_when_subscribed_to_module
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople"

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil]
    ].each do |subscribable_type, subscribable_id|
      assert_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end

    [
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end
  end

  def test_subscriptions_for_when_subscribed_to_class
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person"

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil]
    ].each do |subscribable_type, subscribable_id|
      assert_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end

    [
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end
  end

  def test_subscriptions_for_when_subscribed_to_class_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoPeople::Person", subscribable_id: person.id

    [
      ["GobiertoPeople::Person", person.id]
    ].each do |subscribable_type, subscribable_id|
      assert_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end

    [
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end
  end

  def test_subscriptions_for_when_subscribed_to_subclass
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoCalendars::Event"

    [
      ["GobiertoCalendars::Event", person_event.id],
      ["GobiertoCalendars::Event", nil]
    ].each do |subscribable_type, subscribable_id|
      assert_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end

    [
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end
  end

  def test_subscriptions_for_when_subscribed_to_subclass_instance
    User::Subscription.create! user: user, site: site, subscribable_type: "GobiertoCalendars::Event", subscribable_id: person_event.id

    [
      ["GobiertoCalendars::Event", person_event.id]
    ].each do |subscribable_type, subscribable_id|
      assert_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end

    [
      ["GobiertoCalendars::Event", nil],
      ["GobiertoPeople::Person", person.id],
      ["GobiertoPeople::Person", nil],
      ["GobiertoPeople", nil],
      ["Site", site.id]
    ].each do |subscribable_type, subscribable_id|
      refute_includes subject.subscriptions_for(subscribable_type, subscribable_id, site.id), user.id
    end
  end
end
