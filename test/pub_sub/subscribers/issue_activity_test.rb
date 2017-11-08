# frozen_string_literal: true

require "test_helper"

class Subscribers::IssueActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::IssueActivity.new("activities")
  end

  def issue
    @issue ||= issues(:culture)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_issue_created_event_handling
    assert_difference "Activity.count" do
      subject.issue_created Event.new(name: "activities/issues.issue_created",
                                      payload: { subject: issue,
                                                 author: admin,
                                                 ip: IP,
                                                 site_id: site.id })
    end

    activity = Activity.last
    assert_equal issue, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "issues.issue_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_issue_updated_event_handling
    assert_difference "Activity.count" do
      subject.issue_updated Event.new(name: "activities/issues.issue_updated",
                                      payload: { subject: issue,
                                                 author: admin,
                                                 ip: IP,
                                                 site_id: site.id })
    end

    activity = Activity.last
    assert_equal issue, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "issues.issue_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
