class GobiertoBudgets::ApplicationController < ApplicationController
  include User::SessionHelper

  rescue_from GobiertoBudgets::BudgetLine::RecordNotFound, with: :render_404
  rescue_from GobiertoBudgets::BudgetLine::InvalidSearchConditions do |exception|
    head :bad_request
  end

  layout "gobierto_budgets/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoBudgets") }


  def budgets_elaboration_active?
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_elaboration"]
  end
  helper_method :budgets_elaboration_active?

end
