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
        click_on "Log in"
      end
    end

    def sign_out_admin
      within("header") { click_link "Sign Out" }
    end

    def sign_in_user(user)
      visit new_user_sessions_path

      within("#user-session-form") do
        fill_in :session_email, with: user.email
        fill_in :session_password, with: "gobierto"
        click_on "Log in"
      end
    end

    def sign_out_user
      within("header") { click_link "Sign Out" }
    end
  end
end
