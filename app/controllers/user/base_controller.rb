class User::BaseController < ApplicationController
  include User::SessionHelper

  helper_method :current_user, :user_signed_in?

  layout "application"
end
