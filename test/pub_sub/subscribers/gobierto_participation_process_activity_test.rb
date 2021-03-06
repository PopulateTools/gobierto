# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoParticipationProcessActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoParticipationProcessActivity.new("activities")
  end

  def process
    @process ||= gobierto_participation_processes(:local_budgets_process)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_process_created_event_handling
    assert_difference "Activity.count" do
      subject.process_created Event.new(name: "activities/gobierto_participation_processes.process_created", payload: {
                                          subject: process, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal process, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.process_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_process_updated_event_handling
    assert_difference "Activity.count" do
      subject.process_updated Event.new(name: "activities/gobierto_participation_processes.process_updated", payload: {
                                          subject: process, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal process, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.process_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
