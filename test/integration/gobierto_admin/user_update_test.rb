# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UserUpdateTest < ActionDispatch::IntegrationTest
    def signed_in_admin
      @signed_in_admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:reed)
    end

    def site
      @site ||= user.site
    end

    def test_user_update
      with_signed_in_admin(signed_in_admin) do
        with_selected_site(site) do
          visit edit_admin_user_path(user)

          within "form.edit_user" do
            fill_in "user_name", with: "User Name"
            fill_in "user_email", with: "user@email.dev"

            click_button "Update"
          end

          assert has_message?("User was successfully updated")

          within "form.edit_user" do
            assert has_field?("user_name", with: "User Name")
            assert has_field?("user_email", with: "user@email.dev")
          end
        end
      end
    end
  end
end
