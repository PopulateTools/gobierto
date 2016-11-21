class GobiertoBudgets::ApplicationController < ApplicationController
  include User::SessionHelper

  helper_method :current_user, :user_signed_in?

  layout "gobierto_budgets/application"
end
