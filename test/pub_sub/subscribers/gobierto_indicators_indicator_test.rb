# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoIndicatorsActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  LOCALHOST = "127.0.0.1"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoIndicatorsIndicatorActivity.new("activities")
  end

  def gci_indicator
    @gci_indicator ||= gobierto_indicators_indicators(:gci)
  end

  def ip_address
    @ip_address ||= IPAddr.new(LOCALHOST)
  end

  def create_event
    Event.new(name: "gobierto_indicators.indicator_updated",
              payload: {
                subject: gci_indicator,
                ip: LOCALHOST,
                site_id: site.id,
                indicator_id: gci_indicator.id
              })
  end

  def test_indicators_updated
    assert_difference "Activity.count" do
      subject.indicator_updated(
        create_event
      )
    end

    activity = Activity.last

    assert_equal gci_indicator, activity.subject
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_indicators.indicator_updated", activity.action
    assert_equal site.id, activity.site_id
    refute activity.admin_activity
  end
end
