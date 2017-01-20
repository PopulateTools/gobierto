module GobiertoPeople
  module People
    class PersonEventsController < BaseController
      def index
        @events = @person.events.upcoming.sorted
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
