class GobiertoBudgets::ProvidersController < GobiertoBudgets::ApplicationController

  before_action :check_setting_enabled

  def index
    @year = Date.today.year
    site_stats = GobiertoBudgets::SiteStats.new(site: @site, year: @year)
    @budgets_data_updated_at = site_stats.providers_data_updated_at
  end

  private

  def check_setting_enabled
    render_404 unless budgets_providers_active?
  end

end
