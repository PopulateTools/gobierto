module GobiertoPeople
  module People
    class PastPersonEventsController < PersonEventsController
      def index
        super
        @events = @person.events.past.sorted
      end
    end
  end
end
