module GobiertoAdmin
  class BaseController < ApplicationController
    include SessionHelper
    include SiteSessionHelper
    include LayoutPolicyHelper

    skip_before_action :authenticate_user_in_site
    before_action :authenticate_admin!
    before_action :set_admin_site

    helper_method :current_admin, :admin_signed_in?
    helper_method :current_site, :managing_site?
    helper_method :managed_sites
    helper_method :can_manage_sites?
    helper_method :gobierto_cms_page_preview_url

    rescue_from Errors::NotAuthorized, with: :raise_admin_not_authorized

    layout "gobierto_admin/layouts/application"

    private

    def default_url_options
      { host: ENV['HOST'] }
    end

    def available_locales
      @available_locales ||= I18n.available_locales
    end

    def set_locale
      locale_param = params[:locale]
      locale_cookie = cookies.signed[:locale]

      preferred_locale = (locale_param || locale_cookie || I18n.default_locale).to_s

      I18n.locale = cookies.permanent.signed[:locale] = preferred_locale.to_sym
    end

    def set_admin_site
      return unless current_site

      if request.host != current_site.domain
        if managed_sites && (site = managed_sites.find_by(domain: request.host))
          enter_site(site.id)
          redirect_to admin_root_path
        end
      end
    end

    def gobierto_cms_page_preview_url(page, options = {})
      options.merge!(preview_token: current_admin.preview_token) unless page.active?
      page.to_url(options)
    end

    protected

    def raise_module_not_enabled
      redirect_to(
        admin_root_path,
        alert: t("gobierto_admin.module_helper.not_enabled")
      )
    end

    def raise_module_not_allowed
      redirect_to(
        admin_root_path,
        alert: t("gobierto_admin.module_helper.not_enabled")
      )
    end
  end
end
