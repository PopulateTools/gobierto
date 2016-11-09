require "test_helper"

class Admin::ApplicationHelperTest < ActionView::TestCase
  def regular_admin
    @regular_admin ||= admins(:tony)
  end

  def manager_admin
    @manager_admin ||= admins(:nick)
  end

  def test_admin_label_for_regular
    assert_equal "Tony Stark", admin_label_for(regular_admin)
  end

  def test_admin_label_for_manager
    assert_equal "Nick Fury (manager)", admin_label_for(manager_admin)
  end
end
