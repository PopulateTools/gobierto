# frozen_string_literal: true

class GobiertoBudgets::ProvidersController < GobiertoBudgets::ApplicationController

  before_action :check_setting_enabled

  def index
    respond_to do |format|
      format.html do
        @year = Date.today.year
        site_stats = GobiertoBudgets::SiteStats.new(site: @site, year: @year)
        @budgets_data_updated_at = site_stats.providers_data_updated_at
      end
      format.csv do
        render csv: GobiertoBudgets::Data::Invoices.dump_csv({
          location_id: current_site.organization_id,
          limit: params[:limit],
          sort_desc_by: params[:sort_desc_by],
          sort_asc_by: params[:sort_asc_by],
          date_date_range: params[:date_date_range],
          except_columns: params[:except_columns]
        }), filename: 'invoices.csv'
      end
    end
  end

  private

  def check_setting_enabled
    render_404 unless budgets_providers_active?
  end

end
