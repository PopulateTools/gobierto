# frozen_string_literal: true

module SessionHelpers
  def with_current_admin(admin)
    GobiertoAdmin::BaseController.stub_any_instance(:current_admin, admin) do
      yield
    end
  end

  def with_current_user(user)
    User::BaseController.stub_any_instance(:current_user, user) do
      yield
    end
  end

  def login_admin_for_api(admin)
    post admin_sessions_url, params: { session: { email: admin.email, password: "gobierto" } }
  end
end
