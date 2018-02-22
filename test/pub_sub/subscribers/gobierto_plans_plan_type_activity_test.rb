# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoPlansPlanTypeActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoPlansPlanTypeActivity.new("activities")
  end

  def plan_type
    @plan_type ||= gobierto_plans_plan_types(:pam)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_plan_type_created_event_handling
    assert_difference "Activity.count" do
      subject.plan_type_created Event.new(name: "activities/gobierto_plans.plan_type_created", payload: {
                                          subject: plan_type, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal plan_type, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_plans.plan_type_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_plan_type_updated_event_handling
    assert_difference "Activity.count" do
      subject.plan_type_updated Event.new(name: "activities/gobierto_plans.plan_type_updated", payload: {
                                          subject: plan_type, author: admin, ip: IP, site_id: site.id
                                        })
    end

    activity = Activity.last
    assert_equal plan_type, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_plans.plan_type_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
