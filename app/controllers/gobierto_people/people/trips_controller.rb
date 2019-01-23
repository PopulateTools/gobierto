# frozen_string_literal: true

module GobiertoPeople
  module People
    class TripsController < BaseController

      before_action :check_active_submodules

      def index
        @person_trips = CollectionDecorator.new(@person.trips.between_dates(filter_start_date, filter_end_date).sorted, decorator: TripDecorator)
      end

      def show
        @trip = @person.trips.find(params[:id])
      end

      private

      def check_active_submodules
        redirect_to gobierto_people_root_path unless trips_submodule_active?
      end

    end
  end
end
