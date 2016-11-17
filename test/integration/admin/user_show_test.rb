require "test_helper"

class Admin::UserShowTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = admin_user_path(user)
  end

  def admin
    @admin ||= admins(:nick)
  end

  def user
    @user ||= users(:reed)
  end

  def test_user_show
    with_signed_in_admin(admin) do
      visit @path

      within ".admin_content" do
        assert has_content?(user.name)
        assert has_link?(user.email)
      end
    end
  end
end
