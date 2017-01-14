module GobiertoPeople
  class PersonTravelsController < GobiertoPeople::ApplicationController
    def index
      redirect_to travels_service_url and return if travels_service_url.present?

      redirect_to :back, notice: t(".error")
    end

    private

    def travels_service_url
      APP_CONFIG.dig("gobierto_people", "travels_service_url")
    end
  end
end
