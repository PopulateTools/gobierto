class GobiertoBudgets::ProvidersController < GobiertoBudgets::ApplicationController

  before_action :check_setting_enabled

  def index
    @year = Date.today.year
  end

  private

  def check_setting_enabled
    render_404 unless budgets_providers_active?
  end

end
