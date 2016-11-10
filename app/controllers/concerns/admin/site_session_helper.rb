module Admin::SiteSessionHelper
  extend ActiveSupport::Concern

  private

  def current_site
    return unless session[:site_id]

    @current_site ||= begin
      if (matched_site = Site.find_by(id: session[:site_id]))
        SiteDecorator.new(matched_site)
      end
    end
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
end
