module Integration
  module AuthenticationHelpers
    def with_signed_in_admin(admin)
      sign_in_admin(admin)
      yield
      sign_out_admin
    end

    def with_signed_in_user(user)
      sign_in_user(user)
      yield
      sign_out_user
    end

    private

    def sign_in_admin(admin)
      visit new_admin_sessions_path

      within("#admin-session-form") do
        fill_in :session_email, with: admin.email
        fill_in :session_password, with: "gobierto"

        click_button "Send"
      end
    end

    def sign_out_admin
      within("header") do
        if (javascript_driver?)
          with_hidden_elements do
            find("#admin-sign-out").trigger("click")
          end
        else
          click_link "admin-sign-out"
        end
      end
    end

    def sign_in_user(user)
      visit new_user_sessions_path

      within("#user-session-form") do
        fill_in :user_session_email, with: user.email
        fill_in :user_session_password, with: "gobierto"

        click_button "Log in"
      end
    end

    def sign_out_user
      within("header .user_links") { click_link "Sign out" }
    end
  end
end
