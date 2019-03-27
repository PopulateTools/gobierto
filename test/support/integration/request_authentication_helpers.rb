# frozen_string_literal: true

module Integration
  module RequestAuthenticationHelpers
    DEFAULT_ADMIN_PASSWORD = "gobierto"
    DEFAULT_USER_PASSWORD = "gobierto"

    def with_signed_in_admin(admin)
      sign_in_admin(admin)
      yield
      sign_out_admin
    end

    def with_signed_in_user(user, logout = true)
      with_current_site(user.site) do
        sign_in_user(user)
        yield
        # permits skipping logout on some pages that don't have layout, thus no logout link
        sign_out_user if logout
      end
    end

    def sign_in_admin(admin)
      post(
        admin_sessions_url,
        params: { session: { email: admin.email, password: DEFAULT_ADMIN_PASSWORD } }
      )
    end

    def sign_out_admin
      delete admin_sessions_url
    end

    def sign_in_user(user)
      post(
        sessions_url,
        params: { session: { email: user.email, password: DEFAULT_USER_PASSWORD } }
      )
    end

    def sign_out_user
      delete user_sessions_url
    end
  end
end
