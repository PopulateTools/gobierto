module GobiertoPeople
  class PersonTripsController < GobiertoPeople::ApplicationController

    before_action :check_active_submodules

    def index
      redirect_to trips_service_url and return if trips_service_url.present?

      redirect_back(fallback_location: root_path, notice: t(".error"))
    end

    private

    def check_active_submodules
      # controller shared by two different submodules
      unless statements_submodule_active? || trips_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end
  end
end
