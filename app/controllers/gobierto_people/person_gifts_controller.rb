module GobiertoPeople
  class PersonGiftsController < GobiertoPeople::ApplicationController

    before_action :check_active_submodules

    def index
      redirect_to gifts_service_url and return if gifts_service_url.present?

      redirect_back(fallback_location: root_path, notice: t(".error"))
    end

    private

    def check_active_submodules
      if !statements_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

    def gifts_service_url
      APP_CONFIG.dig("gobierto_people", "gifts_service_url_#{I18n.locale}") ||
        APP_CONFIG.dig("gobierto_people", "gifts_service_url")
    end
  end
end
