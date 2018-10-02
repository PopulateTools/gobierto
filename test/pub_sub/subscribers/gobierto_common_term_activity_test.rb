# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoCommonTermActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoCommonTermActivity.new("activities")
  end

  def term
    @term ||= gobierto_common_terms(:culture_term)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_term_created_event_handling
    assert_difference "Activity.count" do
      subject.term_created Event.new(name: "activities/gobierto_common.term_created",
                                     payload: { subject: term,
                                                author: admin,
                                                ip: IP,
                                                site_id: site.id })
    end

    activity = Activity.last
    assert_equal term, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_common.term_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_term_updated_event_handling
    assert_difference "Activity.count" do
      subject.term_updated Event.new(name: "activities/gobierto_common.term_updated",
                                     payload: { subject: term,
                                                author: admin,
                                                ip: IP,
                                                site_id: site.id })
    end

    activity = Activity.last
    assert_equal term, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_common.term_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
