# frozen_string_literal: true

module GobiertoPeople
  class PersonTripsController < GobiertoPeople::ApplicationController
    include DatesRangeHelper

    before_action :check_active_submodules

    def index
      redirect_to trips_service_url and return if trips_service_url.present?

      redirect_back(fallback_location: root_path, notice: t(".error")) unless engine_overrides?

      @trips = current_site.trips.between_dates(filter_start_date, filter_end_date).order(start_date: :desc).limit(40)
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
