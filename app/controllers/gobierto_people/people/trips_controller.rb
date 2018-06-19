# frozen_string_literal: true

module GobiertoPeople
  module People
    class TripsController < BaseController

      def index
        @person_trips = CollectionDecorator.new(@person.trips, decorator: TripDecorator)
      end

      def show
        @trip = @person.trips.find(params[:id])
      end

    end
  end
end
