require "test_helper"

module GobiertoAdmin
  class UserPasswordChangeTest < ActionDispatch::IntegrationTest
    def signed_in_admin
      @signed_in_admin ||= admins(:nick)
    end

    def user
      @user ||= users(:reed)
    end

    def site
      @site ||= user.source_site
    end

    def test_user_password_change
      with_signed_in_admin(signed_in_admin) do
        with_selected_site(site) do
          visit new_admin_user_passwords_path(user)

          within "form.new_user_password" do
            fill_in "user_password_password", with: "wadus"
            fill_in "user_password_password_confirmation", with: "wadus"

            click_button "Send"
          end

          assert has_content?("User password was successfully updated.")
        end
      end
    end

    def test_invalid_user_password_change
      with_signed_in_admin(signed_in_admin) do
        visit new_admin_user_passwords_path(user)

        within "form.new_user_password" do
          fill_in "user_password_password", with: "wadus"
          fill_in "user_password_password_confirmation", with: "foo"

          click_button "Send"
        end

        refute has_content?("User password was successfully updated.")
      end
    end
  end
end
