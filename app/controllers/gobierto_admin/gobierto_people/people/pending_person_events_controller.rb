module GobiertoAdmin
  module GobiertoPeople
    module People
      class PendingPersonEventsController < PersonEventsController
        def index
          super
          @person_events = @person.events.pending.sorted
        end
      end
    end
  end
end
