# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoPeopleActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def subject
    @subject ||= Subscribers::GobiertoPeopleActivity.new("trackable")
  end

  def test_event_updated_for_non_gobierto_people_event
    assert_no_difference "Activity.count" do
      subject.updated Event.new(name: "foo", payload: {
                                  gid: users(:dennis).to_gid, admin_id: admin.id, site_id: site.id
                                })
    end
  end

  def test_event_updated_for_gobierto_people_person
    activity_subject = gobierto_people_people(:richard)

    assert_difference "Activity.count" do
      subject.updated Event.new(name: "trackable", payload: {
                                  gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
                                })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal activity_subject, activity.recipient
    assert_equal admin, activity.author
    assert_equal "gobierto_people.person.updated", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
