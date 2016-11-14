require "test_helper"

class Subscribers::SiteActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::SiteActivity.new('activities')
  end

  def admin
    @admin ||= admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_site_created_event_handling
    assert_equal 0, Activity.count

    subject.site_created Event.new(name: "activities/sites.site_created", payload: {
      subject: site, author: admin, ip: IP
    })

    assert_equal 1, Activity.count
    activity = Activity.last
    assert_equal site, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "sites.site_created", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_site_updated_event_handling
    assert_equal 0, Activity.count

    subject.site_updated Event.new(name: "activities/sites.site_updated", payload: {
      subject: site, author: admin, ip: IP,
      changes: {"name"=>["Ayuntamiento de Madrid", "Ayuntamiento de los Madriles"]}
    })

    assert_equal 1, Activity.count
    activity = Activity.last
    assert_equal site, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "sites.site_updated", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_site_deleted_event_handling
    assert_equal 0, Activity.count

    site.destroy

    subject.site_deleted Event.new(name: "activities/sites.site_destroyed", payload: {
      subject: site, author: admin, ip: IP
    })

    assert_equal 1, Activity.count
    activity = Activity.last
    assert_nil activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal "sites.site_destroyed", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end
end
