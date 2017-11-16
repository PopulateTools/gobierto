module GobiertoPeople
  class WelcomeController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    before_action :check_active_submodules

    def index
      @people = current_site.people.active.politician.government.sorted.first(10)
      @posts  = current_site.person_posts.active.sorted.last(10)
      @political_groups = get_political_groups
      @home_text = load_home_text
      set_events
    end

    private

    def check_active_submodules
      if active_submodules.size == 1
        redirect_to submodule_path_for(active_submodules.first)
      end
    end

    def set_events
      @events = GobiertoCalendars::Event.by_site(current_site).person_events.by_person_party(Person.parties[:government]).limit(10)

      @events = @events.upcoming.sorted
      if @events.empty?
        @no_upcoming_events = true
        @events = @events.past.sorted_backwards
      end
    end

    def load_home_text
      current_site.gobierto_people_settings &&
        current_site.gobierto_people_settings.send("home_text_#{I18n.locale}")
    end
  end
end
