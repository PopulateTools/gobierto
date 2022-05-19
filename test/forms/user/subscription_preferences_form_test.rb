# frozen_string_literal: true

require "test_helper"

class User::SubscriptionPreferencesFormTest < ActiveSupport::TestCase
  def valid_user_subscription_preferences_form
    @valid_user_subscription_preferences_form ||= User::SubscriptionPreferencesForm.new(
      user: user,
      site: site,
      notification_frequency: User.notification_frequencies["daily"],
      modules: ["", "gobierto_people"],
      gobierto_people_people: ["", person.id.to_s],
      site_to_subscribe: site.id.to_s
    )
  end

  def invalid_user_subscription_preferences_form
    @invalid_user_subscription_preferences_form ||= User::SubscriptionPreferencesForm.new(
      user: user,
      site: site,
      notification_frequency: nil,
      modules: [],
      gobierto_people_people: []
    )
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

  def test_validation
    skip "User subscriptions are disabled"

    assert valid_user_subscription_preferences_form.valid?
  end

  def test_error_messages_with_invalid_attributes
    skip "User subscriptions are disabled"

    refute invalid_user_subscription_preferences_form.valid?

    assert_equal 1, invalid_user_subscription_preferences_form.errors.messages[:notification_frequency].size
  end

  def test_save
    skip "User subscriptions are disabled"

    refute user.subscribed_to?(GobiertoPeople, site)
    refute user.subscribed_to?(person, site)

    assert valid_user_subscription_preferences_form.save

    assert user.subscribed_to?(GobiertoPeople, site)
    assert user.subscribed_to?(person, site)

    assert user.subscribed_to?(site, site)
  end
end
