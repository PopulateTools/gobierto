require "test_helper"

class ActivityDecoratorTest < ActiveSupport::TestCase
  def setup
    super
    @subject = ActivityDecorator.new(activity)
  end

  def activity
    @activity ||= activities(:site_updated_by_admin)
  end

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:tony)
  end

  def test_subject_name
    assert_equal site.name, @subject.subject_name
  end

  def test_author_name
    assert_equal admin.name, @subject.author_name
  end

  def test_recipient_name
    assert_equal "-", @subject.recipient_name
  end
end
