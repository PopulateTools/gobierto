require "test_helper"

class Subscribers::SiteActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  def site
    @site ||= sites(:madrid)
  end

  def invalid_site
    @invalid_site ||= Site.new
  end

  def subject
    @subject ||= Subscribers::SiteActivity.new('activities')
  end

  def admin
    @admin ||= admins(:tony)
  end

  def test_site_created_event_handling_with_valid_site
    assert_equal 0, Activity.count

    subject.site_created Event.new(name: "activities/sites.site_created", payload: {
      subject: site, author: admin, ip: "1.2.3.4"
    })

    assert_equal 1, Activity.count
    activity = Activity.last
    assert_equal site, activity.subject
    assert_equal admin, activity.author
    assert_equal IPAddr.new("1.2.3.4"), activity.subject_ip
    assert_equal "sites.site_created", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_site_created_event_handling_with_invalid_site
    assert_equal 0, Activity.count

    subject.site_created Event.new(name: "activities/sites.site_created", payload: {
      subject: invalid_site, author: admin, ip: "1.2.3.4"
    })

    assert_equal 0, Activity.count
  end

  def test_site_updated_event_handling_with_no_changes
    assert_equal 0, Activity.count

    subject.site_updated Event.new(name: "activities/sites.site_updated", payload: {
      subject: site, author: admin, ip: "1.2.3.4",
      changes: []
    })

    assert_equal 0, Activity.count
  end

  def test_site_updated_event_handling_with_changes_and_invalid_site
    assert_equal 0, Activity.count

    site.name = nil

    subject.site_updated Event.new(name: "activities/sites.site_updated", payload: {
      subject: site, author: admin, ip: "1.2.3.4",
      changes: {"name"=>["Ayuntamiento de Madrid", nil]}
    })

    assert_equal 0, Activity.count
  end

  def test_site_updated_event_handling_with_changes_and_valid_site
    assert_equal 0, Activity.count

    subject.site_updated Event.new(name: "activities/sites.site_updated", payload: {
      subject: site, author: admin, ip: "1.2.3.4",
      changes: {"name"=>["Ayuntamiento de Madrid", "Ayuntamiento de los Madriles"]}
    })

    assert_equal 1, Activity.count
    activity = Activity.last
    assert_equal site, activity.subject
    assert_equal admin, activity.author
    assert_equal IPAddr.new("1.2.3.4"), activity.subject_ip
    assert_equal "sites.site_updated", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_site_deleted_event_handling_with_deleted_site
    assert_equal 0, Activity.count

    site.destroy

    subject.site_deleted Event.new(name: "activities/sites.site_destroyed", payload: {
      subject: site, author: admin, ip: "1.2.3.4"
    })

    assert_equal 1, Activity.count
    activity = Activity.last
    assert_equal site, activity.subject
    assert_equal admin, activity.author
    assert_equal IPAddr.new("1.2.3.4"), activity.subject_ip
    assert_equal "sites.site_destroyed", activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end

  def test_site_deleted_event_handling_with_deleted_site
    assert_equal 0, Activity.count

    subject.site_deleted Event.new(name: "activities/sites.site_destroyed", payload: {
      subject: site, author: admin, ip: "1.2.3.4"
    })

    assert_equal 0, Activity.count
  end
end
