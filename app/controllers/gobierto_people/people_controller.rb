module GobiertoPeople
  class PeopleController < GobiertoPeople::ApplicationController

    include PoliticalGroupsHelper
    include PreviewTokenHelper
    include PeopleClassificationHelper

    before_action :check_active_submodules, except: :show

    def index
      @political_groups = get_political_groups

      set_people
      set_events
      set_present_groups

      respond_to do |format|
        format.html
        format.js
        format.json { render json: @people }
        format.csv  { render csv: GobiertoExports::CSVRenderer.new(@people).to_csv, filename: 'people' }
      end
    end

    def show

      if valid_preview_token?
        redirect_to(
          gobierto_people_root_path,
          alert: t('gobierto_admin.admin_unauthorized')
        ) and return if !admin_permissions_for_person?

        people_scope = current_site.people
      else
        people_scope = current_site.people.active
      end

      @person = PersonDecorator.new(people_scope.find_by!(slug: params[:slug]))

      if active_submodules.size == 1 && agendas_submodule_active?
        redirect_to gobierto_people_person_events_path(@person.slug)
      end

      @upcoming_events = @person.attending_events.upcoming.sorted.first(3)
      @latest_activity = ActivityCollectionDecorator.new(Activity.for_recipient(@person).limit(30).sorted.page(params[:page]))
    end

    private

    def check_active_submodules
      if !officials_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

    def set_people
      @people = current_site.people.active.sorted
      @people = @people.send(Person.categories.key(@person_category)) if @person_category
      @people = @people.send(Person.parties.key(@person_party)) if @person_party
    end

    def set_events
      @events = GobiertoCalendars::Event.by_site(current_site).person_events
      @events = @events.by_person_category(@person_category) if @person_category
      @events = @events.by_person_party(@person_party) if @person_party

      if @events.upcoming.empty?
        @no_upcoming_events = true
        @events = @events.past.sorted_backwards.first(10)
      else
        @events = @events.upcoming.sorted.first(10)
      end
    end

    def admin_permissions_for_person?
      person = current_site.people.find_by(slug: params[:slug])
      if person && current_admin
        ::GobiertoAdmin::GobiertoPeople::PersonPolicy.new(
          current_admin: current_admin,
          person: person
        ).view?
      else
        false
      end
    end

  end
end
