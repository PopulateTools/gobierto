# frozen_string_literal: true

class User::WelcomeController < User::BaseController
  before_action :authenticate_user!

  def index
    redirect_to user_settings_path
  end

end
