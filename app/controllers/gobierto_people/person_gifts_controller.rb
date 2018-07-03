module GobiertoPeople
  class PersonGiftsController < GobiertoPeople::ApplicationController
    include DatesRangeHelper

    before_action :check_active_submodules

    def index
      redirect_to gifts_service_url and return if gifts_service_url.present?

      redirect_back(fallback_location: root_path, notice: t(".error")) unless engine_overrides?
    end

    private

    def check_active_submodules
      # controller shared by two different submodules
      unless statements_submodule_active? || gifts_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

  end
end
