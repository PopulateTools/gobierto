module GobiertoPeople
  class PersonGiftsController < GobiertoPeople::ApplicationController
    def index
      redirect_to gifts_service_url and return if gifts_service_url.present?

      redirect_to :back, notice: t(".error")
    end

    private

    def gifts_service_url
      APP_CONFIG.dig("gobierto_people", "gifts_service_url")
    end
  end
end
