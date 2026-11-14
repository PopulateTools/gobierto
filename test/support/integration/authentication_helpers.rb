# frozen_string_literal: true

module Integration
  module AuthenticationHelpers
    def with_signed_in_admin(admin)
      sign_in_admin(admin)
      yield
      sign_out_admin
    end

    def with_signed_in_user(user, opts = {})
      logout = opts.has_key?(:logout) ? opts[:logout] : true

      with_current_site(user.site, opts.slice(:include_host)) do
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

      # Wait for the sign-in redirect; otherwise it can land after the test's next visit.
      has_no_css?("#admin-session-form")
    rescue Capybara::ElementNotFound
    end

    def sign_out_admin
      # In JavaScript tests the link sits in a hover menu Capybara can't see, so
      # finding it would only wait until the timeout. Those tests reset the
      # session when their JavaScript context ends.
      return if javascript_driver?

      within("header") do
        click_link "admin-sign-out"
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

      # Wait for the sign-in redirect; otherwise it can land after the test's next visit.
      has_no_css?("#user-session-form")
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
