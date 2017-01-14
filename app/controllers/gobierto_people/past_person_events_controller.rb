module GobiertoPeople
  class PastPersonEventsController < PersonEventsController
    def index
      super
      @events = current_site.person_events.past.sorted
    end
  end
end
