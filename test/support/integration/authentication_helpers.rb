# frozen_string_literal: true

module Integration
  module AuthenticationHelpers
    def with_signed_in_admin(admin)
      sign_in_admin(admin)
      yield
      sign_out_admin
    end

    def with_signed_in_user(user, logout=true)
      with_current_site(user.site) do
        sign_in_user(user)
        yield
        # permits skipping logout on some pages that don't have layout, thus no logout link
        sign_out_user if logout
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

    def sign_out_admin
      within("header") do
        if javascript_driver?
          find("#admin-sign-out").click
        else
          click_link "admin-sign-out"
        end
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

    def sign_out_user
      within("header .user_links") do
        # find_link("Sign out", visible: false).execute_script("this.click()")
        find("Sign out", visible: false).execute_script("this.click()")
      end
    rescue Capybara::ElementNotFound
    end
  end
end
