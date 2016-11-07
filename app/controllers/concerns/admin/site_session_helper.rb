module Admin::SiteSessionHelper
  extend ActiveSupport::Concern

  private

  def current_site
    @current_site ||= Site.find_by(id: session[:site_id]) if session[:site_id]
  end

  def managing_site?
    current_site.present?
  end

  def leave_site
    @current_site = session[:site_id] = nil
  end

  def enter_site(site_id)
    session[:site_id] = site_id
  end

  def managed_sites
    @managed_sites ||= current_admin.sites
  end

  def allowed_site?(site_id)
    site_id.to_i.in?(managed_sites.map(&:id))
  end
end
