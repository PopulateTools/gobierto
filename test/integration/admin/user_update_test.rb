require "test_helper"

class Admin::UserUpdateTest < ActionDispatch::IntegrationTest
  def signed_in_admin
    @signed_in_admin ||= admins(:nick)
  end

  def user
    @user ||= users(:reed)
  end

  def test_user_update
    with_signed_in_admin(signed_in_admin) do
      visit edit_admin_user_path(user)

      within "form.edit_user" do
        fill_in "user_name", with: "User Name"
        fill_in "user_email", with: "user@email.dev"

        click_button "Update User"
      end

      assert has_content?("User was successfully updated.")

      within "table.user-list tbody tr#user-item-#{user.id}" do
        assert has_content?("User Name")
        assert has_content?("user@email.dev")
      end
    end
  end
end
