require "test_helper"

class Subscribers::GobiertoBudgetConsultationsTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def subject
    @subject ||= Subscribers::GobiertoBudgetConsultationsActivity.new('trackable')
  end

  def test_event_updated_for_non_gobierto_budget_consultations_event
    assert_no_difference 'Activity.count' do
      subject.updated Event.new(name: "foo", payload: {
        gid: users(:dennis).to_gid, admin_id: admin.id,  site_id: site.id
      })
    end
  end

  def test_event_updated_for_gobierto_budget_consultation_consultation
    activity_subject = gobierto_budget_consultations_consultations(:madrid_open)

    assert_difference 'Activity.count' do
      subject.updated Event.new(name: "trackable", payload: {
        gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
      })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_budget_consultations.consultation.updated", activity.action
    assert_nil   activity.recipient
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end

  def test_event_visibility_level_changed_for_gobierto_budget_consultations_consultation
    activity_subject = gobierto_budget_consultations_consultations(:madrid_open)

    assert_difference 'Activity.count' do
      subject.visibility_level_changed Event.new(name: "trackable", payload: {
        gid: activity_subject.to_gid, admin_id: admin.id, site_id: site.id
      })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_budget_consultations.consultation.published", activity.action
    assert_nil   activity.recipient
    refute activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
