module GobiertoPeople
  class PeopleController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      @people = current_site.people.active.sorted
      @political_groups = get_political_groups
    end

    def show
      @person = PersonDecorator.new(find_person)
      @upcoming_events = @person.events.upcoming.sorted.first(3)

      @latest_activity = ActivityCollectionDecorator.new(Activity.for_recipient(@person).limit(30).sorted)
    end

    private

    def find_person
      current_site.people.active.find(params[:id])
    end
  end
end
