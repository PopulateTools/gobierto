module GobiertoPeople
  module People
    class PersonEventsController < BaseController

      before_action :set_calendar_events, only: [:index]

      def index
        if params[:date]
          @filtering_date = Date.parse(params[:date])
          @events = @person.events.by_date(@filtering_date).sorted.page params[:page]
        else
          @events = @person.events.upcoming.sorted.page params[:page]
        end

        respond_to do |format|
          format.js
          format.html
        end
      end

      def show
        @event = find_event
      end

      private

      def find_event
        @person.events.published.find(params[:id])
      end

      def set_calendar_events
        @calendar_events = @person.events
      end
    end
  end
end
