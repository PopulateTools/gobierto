module GobiertoPeople
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout "gobierto_people/layouts/application"

    before_action { module_enabled!(current_site, "GobiertoPeople") }

    helper_method :gifts_service_url, :trips_service_url, :cache_service, :show_only_calendar?

    private

    def gifts_service_url
      current_site_configuration_variables["gifts_service_url_#{I18n.locale}"] ||
        current_site_configuration_variables["gifts_service_url"]
    end

    def trips_service_url
      current_site_configuration_variables["travels_service_url_#{I18n.locale}"] ||
        current_site_configuration_variables["travels_service_url"]
    end

    def current_site_configuration_variables
      @current_site_configuration_variables ||= current_site.configuration.configuration_variables
    end

    def cache_service
      @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoPeople")
    end

    def show_only_calendar?
      params[:only_calendar].present?
    end

    def cache_service
      @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoPeople")
    end

    def cache_path
      "#{current_site.cache_key_with_version}/#{current_module}/#{self.controller_name}/#{self.action_name}/#{I18n.locale}"
    end

  end
end
