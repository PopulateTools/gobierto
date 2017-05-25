# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    module People
      class PublishedPersonEventsController < PersonEventsController
        def index
          super
          @person_events = @person.events.published.sorted
        end
      end
    end
  end
end
