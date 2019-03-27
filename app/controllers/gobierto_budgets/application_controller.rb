# frozen_string_literal: true

class GobiertoBudgets::ApplicationController < ApplicationController
  include User::SessionHelper

  rescue_from GobiertoBudgets::BudgetLine::RecordNotFound, with: :render_404
  rescue_from GobiertoBudgets::BudgetLine::InvalidSearchConditions do |exception|
    head :bad_request
  end

  layout "gobierto_budgets/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoBudgets") }

  def set_current_site
    @site = SiteDecorator.new(current_site)
  end
end
