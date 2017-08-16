# frozen_string_literal: true

require "test_helper"

class Subscribers::CensusActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::CensusActivity.new("users")
  end

  def census_import
    @census_import ||= gobierto_admin_census_imports(:tony_madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_census_imported_event_handling
    assert_difference "Activity.count" do
      subject.census_imported Event.new(name: "census/census_imported", payload: {
                                          author: admin, ip: IP, subject: census_import
                                        })
    end

    activity = Activity.last
    assert_equal census_import, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "census.census_imported", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end
end
