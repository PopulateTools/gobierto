# frozen_string_literal: true

require 'test_helper'

class Subscribers::ScopeActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = '1.2.3.4'

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::ScopeActivity.new('activities')
  end

  def scope
    @scope ||= gobierto_common_scopes(:old_town)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new(IP)
  end

  def event_payload
    @event_payload ||= {
      subject: scope,
      author: admin,
      ip: IP,
      site_id: site.id
    }
  end

  def test_scope_created_event_handling
    assert_difference 'Activity.count' do
      event = Event.new(
                name: 'activities/scopes.scope_created',
                payload: event_payload
              )

      subject.scope_created(event)
    end

    activity = Activity.last

    assert activity.admin_activity
    assert_equal scope, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal 'scopes.scope_created', activity.action
    assert_equal site.id, activity.site_id
  end

  def test_scope_updated_event_handling
    assert_difference 'Activity.count' do
      event = Event.new(
        name: 'activities/scopes.scope_updated',
        payload: event_payload
      )

      subject.scope_updated(event)
    end

    activity = Activity.last
    
    assert activity.admin_activity
    assert_equal scope, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal 'scopes.scope_updated', activity.action
    assert_equal site.id, activity.site_id
  end
end
