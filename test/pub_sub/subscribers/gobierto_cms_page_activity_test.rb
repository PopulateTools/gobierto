# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoCmsPageActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoCmsPageActivity.new("activities")
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

  def test_page_created_event_handling
    assert_difference "Activity.count" do
      subject.page_created Event.new(name: "activities/gobierto_cms_pages.page_created", payload: {
                                       subject: page, author: admin, ip: IP, site_id: site.id
                                     })
    end

    activity = Activity.last
    assert_equal page, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_cms.page_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_page_updated_event_handling
    assert_difference "Activity.count" do
      subject.page_updated Event.new(name: "activities/gobierto_cms_pages.page_updated", payload: {
                                       subject: page, author: admin, ip: IP, site_id: site.id
                                     })
    end

    activity = Activity.last
    assert_equal page, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_cms.page_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
