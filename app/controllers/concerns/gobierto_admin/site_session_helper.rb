module GobiertoAdmin
  module SiteSessionHelper
    extend ActiveSupport::Concern

    private

    def current_site
      @current_site ||= begin
        if session[:admin_site_id] && (matched_site = Site.find_by(id: session[:admin_site_id]))
          SiteDecorator.new(matched_site)
        else
          SiteDecorator.new(managed_sites.first) if managed_sites.present?
        end
      end
    end

    def managing_site?
      current_site.present?
    end

    def leave_site
      @current_site = session[:admin_site_id] = nil
    end

    def enter_site(site_id)
      session[:admin_site_id] = site_id
    end

    def managed_sites
      @managed_sites ||= begin
        current_admin.sites.alphabetically_sorted if admin_signed_in?
      end
    end
  end
end
