module GobiertoPeople
  class WelcomeController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      @people = current_site.people.active.politician.government.last(10)
      @events = current_site.person_events.upcoming.sorted.first(10)
      @posts  = current_site.person_posts.active.sorted.last(10)
      @political_groups = get_political_groups
      @home_text = load_home_text
    end

    private

    def load_home_text
      current_site.gobierto_people_settings.find_by(key: "home_text_#{I18n.locale}").try(:value)
    end
  end
end
