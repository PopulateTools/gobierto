require "test_helper"

module GobiertoAdmin
  class UserWelcomeMessageCreateTest < ActionDispatch::IntegrationTest
    def signed_in_admin
      @signed_in_admin ||= gobierto_admin_admins(:nick)
    end

    def user
      @user ||= users(:reed)
    end

    def site
      @site ||= user.source_site
    end

    def test_user_welcome_message_create
      with_signed_in_admin(signed_in_admin) do
        with_selected_site(site) do
          visit edit_admin_user_path(user)

          click_link "Reenviar mail de bienvenida"

          assert has_message?("The welcome message has been sent")
        end
      end
    end
  end
end
