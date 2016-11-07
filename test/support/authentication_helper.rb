module AuthenticationHelper
  def with_signed_in_admin(admin)
    sign_in_admin(admin)
    yield
    sign_out_admin
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
    within("header") { click_link "Sign out" }
  end
end
