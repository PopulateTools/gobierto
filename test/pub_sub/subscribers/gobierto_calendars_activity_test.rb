# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoCalendarsActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def subject
    @subject ||= Subscribers::GobiertoCalendarsActivity.new("trackable")
  end

  def test_event_updated_for_gobierto_calendars_event
    activity_subject = gobierto_calendars_events(:richard_published)
    assert_difference "Activity.count" do
      subject.updated Event.new(name: "trackable", payload: {
                                  gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
                                })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal gobierto_people_people(:richard), activity.recipient
    assert_equal admin, activity.author
    assert_equal "gobierto_calendars.event.updated", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_event_visibility_level_changed_for_gobierto_calendars_event
    activity_subject = gobierto_calendars_events(:richard_published)

    assert_difference "Activity.count" do
      subject.visibility_level_changed Event.new(name: "trackable", payload: {
                                                   gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
                                                 })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal gobierto_people_people(:richard), activity.recipient
    assert_equal admin, activity.author
    assert_equal "gobierto_calendars.event.published", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_event_state_changed_for_gobierto_calendars_event
    activity_subject = gobierto_calendars_events(:richard_published)

    assert_difference "Activity.count" do
      subject.visibility_level_changed Event.new(name: "trackable", payload: {
                                                   gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
                                                 })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal gobierto_people_people(:richard), activity.recipient
    assert_equal admin, activity.author
    assert_equal "gobierto_calendars.event.published", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
