require "test_helper"

class Subscribers::GobiertoBudgetConsultationsConsultationResponseActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = "1.2.3.4"

  def site
    @site ||= consultation.site
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def consultation
    @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
  end

  def subject
    @subject ||= Subscribers::GobiertoBudgetConsultationsConsultationResponseActivity.new('activities/gobierto_budget_consultations_consultation_response')
  end

  def activity_subject
    @activity_subject ||= gobierto_budget_consultations_consultation_responses(:dennis_madrid_open)
  end

  def test_event_created
    assert_difference 'Activity.count' do
      subject.consultation_response_created Event.new(name: "consultation_response_created", payload: {
        author: admin,  site_id: site.id, subject: activity_subject, recipient: consultation, ip: IP
      })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_budget_consultations.consultation_response_created", activity.action
    assert_equal consultation, activity.recipient
    assert activity.admin_activity
    assert_equal site.id, activity.site_id

  end

  def test_event_deleted
    assert_difference 'Activity.count' do
      subject.consultation_response_deleted Event.new(name: "consultation_response_deleted", payload: {
        author: admin, site_id: site.id, subject: activity_subject, recipient: consultation, ip: IP
      })
    end

    activity = Activity.last
    assert_equal activity_subject, activity.subject
    assert_equal admin, activity.author
    assert_equal "gobierto_budget_consultations.consultation_response_deleted", activity.action
    assert_equal consultation, activity.recipient
    assert activity.admin_activity
    assert_equal site.id, activity.site_id
  end
end
