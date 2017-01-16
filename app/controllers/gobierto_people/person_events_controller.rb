module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      @events = current_site.person_events.upcoming.sorted
      @people = current_site.people.active.sorted
      @political_groups = get_political_groups
    end
  end
end
