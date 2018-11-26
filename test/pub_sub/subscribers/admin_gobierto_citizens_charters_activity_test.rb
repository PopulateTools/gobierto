# frozen_string_literal: true

require "test_helper"

class Subscribers::AdminGobiertoCitizensChartersActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::AdminGobiertoCitizensChartersActivity.new("activities/admin_gobierto_citizens_charters")
  end

  def service
    @service ||= gobierto_citizens_charters_services(:teleassistance)
  end

  def charter
    @charter ||= gobierto_citizens_charters_charters(:teleassistance_charter)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new("1.2.3.4")
  end

  def payload(subject)
    { gid: subject.to_gid, site_id: site.id, admin_id: admin.id }
  end

  def test_editions_edition_attribute_changed_event_handling
    assert_difference "Activity.count" do
      subject.editions_edition_attribute_changed Event.new(name: "edition_updated", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.edition_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_editions_created_event_handling
    assert_difference "Activity.count" do
      subject.editions_created Event.new(name: "edition_created", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.edition_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_editions_deleted_event_handling
    assert_difference "Activity.count" do
      subject.editions_deleted Event.new(name: "edition_deleted", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.edition_deleted", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_commitments_commitment_attribute_changed_event_handling
    assert_difference "Activity.count" do
      subject.commitments_commitment_attribute_changed Event.new(name: "commitment_updated", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.commitment_updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_commitments_visibility_level_changed_event_handling
    assert_difference "Activity.count" do
      subject.commitments_visibility_level_changed Event.new(name: "commitment_published", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.commitment_published", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_commitments_created_event_handling
    assert_difference "Activity.count" do
      subject.commitments_created Event.new(name: "commitment_created", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.commitment_created", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_commitments_archived_event_handling
    assert_difference "Activity.count" do
      subject.commitments_archived Event.new(name: "commitment_archived", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.commitment_archived", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_charter_attribute_changed_event_handling
    assert_difference "Activity.count" do
      subject.charter_attribute_changed Event.new(name: "updated", payload: payload(charter))
    end

    activity = Activity.last
    assert_equal charter, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.charter.updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_service_attribute_changed_event_handling
    assert_difference "Activity.count" do
      subject.service_attribute_changed Event.new(name: "updated", payload: payload(service))
    end

    activity = Activity.last
    assert_equal service, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_citizens_charters.service.updated", activity.action
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_visibility_level_changed_event_handling
    assert_difference "Activity.count", 2 do
      subject.visibility_level_changed Event.new(name: "published", payload: payload(charter))

      activity = Activity.last
      assert_equal charter, activity.subject
      assert_equal admin, activity.author
      assert_equal "gobierto_citizens_charters.charter.published", activity.action
      assert activity.admin_activity
      assert_equal site.id, activity.site_id

      subject.visibility_level_changed Event.new(name: "published", payload: payload(service))

      activity = Activity.last
      assert_equal service, activity.subject
      assert_equal admin, activity.author
      assert_equal "gobierto_citizens_charters.service.published", activity.action
      assert activity.admin_activity
      assert_equal site.id, activity.site_id
    end
  end

  def test_created_event_handling
    assert_difference "Activity.count", 2 do
      subject.created Event.new(name: "created", payload: payload(charter))

      activity = Activity.last
      assert_equal charter, activity.subject
      assert_equal admin, activity.author
      assert_equal "gobierto_citizens_charters.charter.created", activity.action
      assert activity.admin_activity
      assert_equal site.id, activity.site_id

      subject.created Event.new(name: "created", payload: payload(service))

      activity = Activity.last
      assert_equal service, activity.subject
      assert_equal admin, activity.author
      assert_equal "gobierto_citizens_charters.service.created", activity.action
      assert activity.admin_activity
      assert_equal site.id, activity.site_id
    end
  end

  def test_archived_event_handling
    assert_difference "Activity.count", 2 do
      subject.archived Event.new(name: "archived", payload: payload(charter))

      activity = Activity.last
      assert_equal charter, activity.subject
      assert_equal admin, activity.author
      assert_equal "gobierto_citizens_charters.charter.archived", activity.action
      assert activity.admin_activity
      assert_equal site.id, activity.site_id

      subject.archived Event.new(name: "archived", payload: payload(service))

      activity = Activity.last
      assert_equal service, activity.subject
      assert_equal admin, activity.author
      assert_equal "gobierto_citizens_charters.service.archived", activity.action
      assert activity.admin_activity
      assert_equal site.id, activity.site_id
    end
  end
end
