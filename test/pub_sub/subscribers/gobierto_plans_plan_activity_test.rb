# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoPlansPlanActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoPlansPlanActivity.new("activities")
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_plan_created_event_handling
    assert_difference "Activity.count" do
      subject.plan_created Event.new(name: "activities/gobierto_plans.plan_created", payload: {
                                          subject: plan, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal plan, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_plans.plan_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_plan_updated_event_handling
    assert_difference "Activity.count" do
      subject.plan_updated Event.new(name: "activities/gobierto_plans.plan_updated", payload: {
                                          subject: plan, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal plan, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_plans.plan_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
