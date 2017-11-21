# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoParticipationContributionActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoParticipationContributionActivity.new("activities")
  end

  def contribution
    @contribution ||= gobierto_participation_contributions(:cinema)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_contribution_created_event_handling
    assert_difference "Activity.count" do
      subject.contribution_created Event.new(name: "activities/gobierto_participation.contribution_created", payload: {
                                               subject: contribution, author: admin, ip: IP, site_id: site.id
                                             })
    end

    activity = Activity.last
    assert_equal contribution, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.contribution_created", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
