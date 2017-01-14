module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    def index
      @events = current_site.person_events.upcoming.sorted
      @people = current_site.people.active.sorted
    end
  end
end
