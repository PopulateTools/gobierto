module GobiertoPeople
  module People
    class PastPersonEventsController < People::PersonEventsController
      def index
        @events = @person.events.past.sorted.page params[:page]
        respond_to do |format|
          format.js { render 'gobierto_people/people/person_events/index' }
          format.html
        end
      end
    end
  end
end
