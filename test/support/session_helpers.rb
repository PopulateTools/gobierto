module SessionHelpers
  def with_current_admin(admin)
    Admin::BaseController.stub_any_instance(:current_admin, admin) do
      yield
    end
  end
end
