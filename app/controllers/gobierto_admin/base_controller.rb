# frozen_string_literal: true

module GobiertoAdmin
  class BaseController < ApplicationController
    include SessionHelper
    include SiteSessionHelper
    include LayoutPolicyHelper
    include ::GobiertoCms::PageHelper

    skip_before_action :authenticate_user_in_site
    before_action :authenticate_admin!, :set_admin_site

    helper_method :current_admin, :admin_signed_in?, :current_site, :managing_site?,
                  :managed_sites, :can_manage_sites?, :gobierto_cms_page_preview_path,
                  :preview_item_url, :module_doc_url

    rescue_from Errors::NotAuthorized, with: :raise_admin_not_authorized

    layout "gobierto_admin/layouts/application"

    private

    def default_url_options
      { host: ENV["HOST"] }
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
        end
      end
    end

    def preview_item_url
      @preview_item_url || @preview_item&.to_url(preview: true, admin: current_admin)
    end

    def current_admin_module
      current_module == "gobierto_admin" && params[:controller].split("/")[1].camelize
    end

    def module_doc_url
      default_doc_url = "https://gobierto.readme.io/docs/administraci%C3%B3n-de-un-sitio"
      begin
        current_admin_module.constantize.try(:doc_url) || default_doc_url
      rescue NameError
        default_doc_url
      end
    end

    protected

    def raise_module_not_enabled(_redirect = true)
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

    def raise_action_not_allowed
      redirect_to(
        admin_root_path,
        alert: t("gobierto_admin.module_helper.not_enabled")
      )
    end

    def gobierto_cms_page_preview_path(page, options = {})
      options[:preview_token] = current_admin.preview_token unless page.active?
      gobierto_cms_page_or_news_path(page, options)
    end
  end
end
