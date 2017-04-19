module GobiertoPeople
  module People
    class PastPersonEventsController < People::PersonEventsController
      def index
        @events = @person.events.past.sorted
      end
    end
  end
end
