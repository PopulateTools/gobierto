# frozen_string_literal: true

module GobiertoPeople
  module People
    class TripsController < BaseController
      def index
        @person_trips = @person.trips
      end

      def show
        @trip = @person.trips.find(params[:id])
      end
    end
  end
end
