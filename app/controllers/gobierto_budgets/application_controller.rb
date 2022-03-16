class GobiertoBudgets::ApplicationController < ApplicationController
  include User::SessionHelper

  helper_method :cache_path, :cache_service

  rescue_from GobiertoBudgets::BudgetLine::RecordNotFound, with: :render_404
  rescue_from GobiertoBudgets::BudgetLine::InvalidSearchConditions do |exception|
    head :bad_request
  end

  layout "gobierto_budgets/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoBudgets") }

  def set_current_site
    @site = SiteDecorator.new(current_site)
  end

  private

  def cache_service
    @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoBudgets")
  end

  def cache_path
    "#{current_site.cache_key_with_version}/#{current_module}/#{self.controller_name}/#{self.action_name}/#{I18n.locale}"
  end
end
