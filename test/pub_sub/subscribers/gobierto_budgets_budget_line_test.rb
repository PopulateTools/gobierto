# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoBudgetsBudgetLineActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  LOCALHOST = "127.0.0.1"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoBudgetsBudgetLineActivity.new("activities")
  end

  def ip_address
    @ip_address ||= IPAddr.new(LOCALHOST)
  end

  def create_event
    Event.new(name: "gobierto_budgets.budgets_updated",
              payload: {
                subject: site,
                ip: LOCALHOST,
                site_id: site.id
              })
  end

  def test_budgets_updated
    assert_difference "Activity.count" do
      subject.budgets_updated(
        create_event
      )
    end

    activity = Activity.last

    assert_equal site, activity.subject
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_budgets.budgets_updated", activity.action
    assert_equal site.id, activity.site_id
    refute activity.admin_activity
  end
end
