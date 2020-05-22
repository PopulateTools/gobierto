# frozen_string_literal: true

module Integration
  module AuthenticationHelpers
    def with_signed_in_admin(admin)
      sign_in_admin(admin)
      yield
    end

    def with_signed_in_user(user, opts = {})
      with_current_site(user.site, opts.slice(:include_host)) do
        sign_in_user(user)
        yield
      end
    end

    private

    def sign_in_admin(admin)
      visit new_admin_sessions_path

      within("#admin-session-form") do
        fill_in :session_email, with: admin.email
        fill_in :session_password, with: "gobierto"

        click_button "Send"
      end
    rescue Capybara::ElementNotFound
    end

    def sign_in_user(user)
      visit new_user_sessions_path

      within("#user-session-form") do
        fill_in :user_session_email, with: user.email
        fill_in :user_session_password, with: "gobierto"

        click_button "Log in"
      end
    rescue Capybara::ElementNotFound
    end
  end
end
