# frozen_string_literal: true

require "test_helper"

class Subscribers::GobiertoAttachmentsActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::GobiertoAttachmentsActivity.new("trackable")
  end

  def attachment
    @attachment ||= gobierto_attachments_attachments(:pdf_collection_attachment)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def test_attachment_updated_event_handling
    activity_subject = gobierto_attachments_attachments(:pdf_collection_attachment)

    assert_difference "Activity.count" do
      subject.updated Event.new(name: "trackable", payload: {
                                  gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
                                })
    end

    activity = Activity.last
    assert_equal attachment, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_attachments.attachment.updated", activity.action
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
