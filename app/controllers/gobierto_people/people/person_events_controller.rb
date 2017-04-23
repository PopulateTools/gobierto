module GobiertoPeople
  module People
    class PersonEventsController < BaseController
      def index
        @events = @person.events.upcoming.sorted.page params[:page]
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
    end
  end
end
