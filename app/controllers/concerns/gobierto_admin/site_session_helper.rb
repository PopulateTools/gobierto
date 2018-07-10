module GobiertoAdmin
  module SiteSessionHelper
    extend ActiveSupport::Concern

    private

    def current_site
      @current_site ||= begin
        site = if session[:admin_site_id] && (matched_site = Site.find_by(id: session[:admin_site_id]))
          SiteDecorator.new(matched_site)
        elsif managed_sites.present?
          SiteDecorator.new(managed_sites.include?(site_from_domain) ? site_from_domain : managed_sites.first)
        end
        ::GobiertoCore::CurrentScope.current_site = site
        site
      end
    end

    def managing_site?
      current_site.present? && current_admin.managing_user?
    end

    def leave_site
      @current_site = session[:admin_site_id] = nil
    end

    def enter_site(site_id)
      session[:admin_site_id] = site_id
    end

    def managed_sites
      @managed_sites ||= begin
        current_admin.sites if admin_signed_in?
      end
    end

    def request_domain
      (request.env["HTTP_HOST"] || request.env["SERVER_NAME"] || request.env["SERVER_ADDR"]).split(":").first
    end

    def site_from_domain
      Site.find_by(domain: request_domain)
    end
  end
end
