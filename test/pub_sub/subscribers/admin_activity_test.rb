# frozen_string_literal: true

require "test_helper"

class Subscribers::AdminActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::AdminActivity.new("admins")
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def admin_subject
    @admin_subject ||= gobierto_admin_admins(:natasha)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_invitation_created_event_handling
    assert_difference "Activity.count" do
      subject.invitation_created Event.new(name: "admins/admins.invitation_created", payload: {
                                             author: admin, ip: IP
                                           })
    end

    activity = Activity.last
    assert_nil activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "admins.invitation_created", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_invitation_accepted_event_handling
    assert_difference "Activity.count" do
      subject.invitation_accepted Event.new(name: "admins/admins.invitation_accepted", payload: {
                                              subject: admin, author: admin, ip: IP
                                            })
    end

    activity = Activity.last
    assert_equal admin, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "admins.invitation_accepted", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_admin_created_event_handling
    assert_difference "Activity.count" do
      subject.admin_created Event.new(name: "admins/admins.admin_created", payload: {
                                        subject: admin_subject, author: admin, ip: IP
                                      })
    end

    activity = Activity.last
    assert_equal admin_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "admins.admin_created", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_admin_updated_event_handling_no_changes
    assert_no_difference "Activity.count" do
      subject.admin_updated Event.new(name: "admins/admins.admin_updated", payload: {
                                        subject: admin_subject, author: admin, ip: IP,
                                        changes: []
                                      })
    end
  end

  def test_admin_updated_event_handling
    assert_difference "Activity.count" do
      subject.admin_updated Event.new(name: "admins/admins.admin_updated", payload: {
                                        subject: admin_subject, author: admin, ip: IP,
                                        changes: ["name" => "Foo"]
                                      })
    end

    activity = Activity.last
    assert_equal admin_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "admins.admin_updated", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_admin_updated_event_handling_for_authorization_level_updated
    assert_difference "Activity.count" do
      subject.admin_updated Event.new(name: "admins/admins.admin_authorization_level_updated", payload: {
                                        subject: admin_subject, author: admin, ip: IP,
                                        changes: { "authorization_level" => "manager" }
                                      })
    end

    activity = Activity.last
    assert_equal admin_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "admins.admin_authorization_level_updated", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end
end
