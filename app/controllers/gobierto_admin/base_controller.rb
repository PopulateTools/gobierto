module GobiertoAdmin
  class BaseController < ApplicationController
    include SessionHelper
    include SiteSessionHelper
    include LayoutPolicyHelper
    include ModuleHelper

    skip_before_action :authenticate_user_in_site
    before_action :authenticate_admin!

    helper_method :current_admin, :admin_signed_in?
    helper_method :current_site, :managing_site?
    helper_method :managed_sites
    helper_method :can_manage_sites?

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
      Rails.logger.info "ADMIN SET LOCALE"
      locale_param = params[:locale]
      locale_cookie = cookies.signed[:locale]

      preferred_locale = (locale_param || locale_cookie || I18n.default_locale).to_s

      I18n.locale = cookies.permanent.signed[:locale] = preferred_locale.to_sym
    end
  end
end
