class User::WelcomeController < User::BaseController
  before_action :authenticate_user!

  def index
    @dashboard_data = retrieve_dashboard_data
  end

  private

  def retrieve_dashboard_data
    []
  end
end
