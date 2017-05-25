# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    module People
      class PastPersonEventsController < PersonEventsController
        def index
          super
          @person_events = @person.events.past.sorted
        end
      end
    end
  end
end
