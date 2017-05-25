# frozen_string_literal: true

require 'test_helper'

class Subscribers::UserActivityTest < ActiveSupport::TestCase
  class Event < OpenStruct; end

  IP = '1.2.3.4'

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= Subscribers::UserActivity.new('users')
  end

  def user
    @user ||= users(:dennis)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def ip_address
    @ip_address ||= IPAddr.new('1.2.3.4')
  end

  def test_user_updated_event_handling
    assert_difference 'Activity.count' do
      subject.user_updated Event.new(name: 'users/user_updated', payload: {
                                       author: admin, ip: IP, subject: user,
                                       changes: { name: 'Foo' }
                                     })
    end

    activity = Activity.last
    assert_equal user, activity.subject
    assert_equal admin, activity.author
    assert_equal ip_address, activity.subject_ip
    assert_equal 'users.user_updated', activity.action
    assert activity.admin_activity
    assert_nil activity.site_id
  end
end
