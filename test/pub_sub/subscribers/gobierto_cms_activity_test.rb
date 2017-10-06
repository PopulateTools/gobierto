# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoCmsActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoCmsActivity.new("trackable")
  end

  def page
    @page ||= gobierto_cms_pages(:consultation_faq)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_page_updated_event_handling
    activity_subject = gobierto_cms_pages(:consultation_faq)

    assert_difference "Activity.count" do
      subject.updated Event.new(name: "trackable", payload: {
                                  gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
                                })
    end

    activity = Activity.last
    assert_equal page, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_cms.page.updated", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
