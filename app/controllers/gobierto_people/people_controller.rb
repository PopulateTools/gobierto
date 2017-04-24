module GobiertoPeople
  class PeopleController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    before_action :check_active_submodules, except: :show

    def index

      @political_groups = get_political_groups

      set_people
      set_events

      respond_to do |format|
        format.html
        format.js
        format.json { render json: @people }
        format.csv  { render csv: GobiertoExports::CSVRenderer.new(@people).to_csv, filename: 'people' }
      end
    end

    def show
      @person = PersonDecorator.new(find_person)

      if active_submodules.size == 1 && agendas_submodule_active?
        redirect_to gobierto_people_person_events_path @person
      end

      @upcoming_events = @person.events.upcoming.sorted.first(3)
      @latest_activity = ActivityCollectionDecorator.new(Activity.for_recipient(@person).limit(30).sorted.page(params[:page]))
    end

    private

    def check_active_submodules
      if !officials_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

    def find_person
      current_site.people.active.find(params[:id])
    end

    def set_people
      @people = current_site.people.active.sorted
      @people = @people.send(Person.categories.key(@person_category)) if @person_category
      @people = @people.send(Person.parties.key(@person_party)) if @person_party
    end

    def set_events
      @events = current_site.person_events
      @events = @events.by_person_category(@person_category) if @person_category
      @events = @events.by_person_party(@person_party) if @person_party

      if @events.upcoming.empty?
        @no_upcoming_events = true
        @events = @events.past.sorted_backwards.first(10)
      else
        @events = @events.upcoming.sorted.first(10)
      end
    end

  end
end
