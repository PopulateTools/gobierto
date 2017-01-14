module GobiertoPeople
  class WelcomeController < GobiertoPeople::ApplicationController
    def index
      @people = current_site.people.active.sorted.last(10)
      @events = current_site.person_events.upcoming.sorted.first(10)
      @posts  = current_site.person_posts.active.sorted.last(10)
    end
  end
end
