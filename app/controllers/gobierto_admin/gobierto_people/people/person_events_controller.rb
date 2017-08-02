module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonEventsController < People::BaseController
        def index
          @collection = @person.events_collection
          @events_presenter = GobiertoAdmin::GobiertoCalendars::EventsPresenter.new(@collection)
          @events = @person.events.sorted
        end
      end
    end
  end
end
