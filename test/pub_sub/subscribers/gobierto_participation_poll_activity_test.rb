# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoParticipationPollActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoParticipationPollActivity.new("activities")
  end

  def poll
    @poll ||= gobierto_participation_polls(:public_spaces_future)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_poll_created_event_handling
    assert_difference "Activity.count" do
      subject.poll_created Event.new(name: "activities/gobierto_participation_polls.poll_created", payload: {
                                          subject: poll, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal poll, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.poll_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_poll_updated_event_handling
    assert_difference "Activity.count" do
      subject.poll_updated Event.new(name: "activities/gobierto_participation_polls.poll_updated", payload: {
                                          subject: poll, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal poll, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.poll_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
