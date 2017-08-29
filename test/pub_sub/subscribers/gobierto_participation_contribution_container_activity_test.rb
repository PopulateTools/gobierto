# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoParticipationContributionContainerActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoParticipationContributionContainerActivity.new("activities")
  end

  def contribution_container
    @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_contribution_container_created_event_handling
    assert_difference "Activity.count" do
      subject.contribution_container_created Event.new(name: "activities/gobierto_participation.contribution_container_created", payload: {
                                                         subject: contribution_container, author: admin, ip: IP, site_id: site.id
                                                       })
    end

    activity = Activity.last
    assert_equal contribution_container, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.contribution_container_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_contribution_container_updated_event_handling
    assert_difference "Activity.count" do
      subject.contribution_container_updated Event.new(name: "activities/gobierto_participation.contribution_container_updated", payload: {
                                                         subject: contribution_container, author: admin, ip: IP, site_id: site.id
                                                       })
    end

    activity = Activity.last
    assert_equal contribution_container, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "gobierto_participation.contribution_container_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
