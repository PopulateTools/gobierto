module GobiertoPeople
  class PeopleController < GobiertoPeople::ApplicationController

    include PoliticalGroupsHelper
    include PreviewTokenHelper
    include PeopleClassificationHelper
    include DatesRangeHelper
    include FilterByActivitiesHelper

    layout :resolve_layout

    before_action :check_active_submodules, except: :show

    LAST_ITEMS_SIZE = 4

    def index
      @political_groups = get_political_groups

      set_departments
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
        redirect_to gobierto_people_person_events_path(@person.slug) and return
      end

      @upcoming_events = @person.attending_events.upcoming.sorted.first(3)
      @latest_activity = ActivityCollectionDecorator.new(Activity.for_recipient(@person).limit(30).sorted.page(params[:page]))

      # custom engine
      @last_events = QueryWithEvents.new(
        source: @person.attending_events
                       .published
                       .with_interest_group
                       .sorted_backwards
                       .limit(LAST_ITEMS_SIZE),
        start_date: filter_start_date,
        end_date: filter_end_date
      )

      last_trips_relation = @person.trips.between_dates(filter_start_date, filter_end_date).sorted.limit(LAST_ITEMS_SIZE)
      @last_trips = CollectionDecorator.new(last_trips_relation, decorator: TripDecorator)
      @last_invitations = @person.invitations.between_dates(filter_start_date, filter_end_date).sorted.limit(LAST_ITEMS_SIZE)
      @last_gifts = @person.received_gifts.between_dates(filter_start_date, filter_end_date).sorted.limit(LAST_ITEMS_SIZE)
      check_people_resources_with_content
    end

    private

    def check_active_submodules
      if !officials_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

    def engine_people_resources_with_content
      return [] unless site_configuration_dates_range?
      GobiertoPeople.custom_engine_resources.select do |resources|
        submodule = resources == "events" ? "agendas" : resources
        active_submodules.include?(submodule) && instance_variable_get("@last_#{resources}")&.exists?
      end
    end

    def check_people_resources_with_content
      return unless (resources = engine_people_resources_with_content).count == 1
      resources = resources.first
      path = if resources == "events"
               if @upcoming_events.present?
                 gobierto_people_person_events_path(@person.slug)
               else
                 gobierto_people_person_past_events_path(@person.slug, date_range_params.merge(page: false))
               end
             else
               send("gobierto_people_person_#{resources}_path", @person.slug, date_range_params)
             end
      redirect_to path
    end

    def set_people
      @people = current_site.people.active.sorted

      if current_site.date_filter_configured?
        @people = QueryWithActivities.new(
          source: @people,
          start_date: filter_start_date,
          end_date: filter_end_date,
          include_joins: { events: :attending_events, gifts: :received_gifts, invitations: :invitations, trips: :trips }
        ).sorted
      end

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

    def set_departments
      @sidebar_departments = filter_by_activities(
        source: current_site.departments,
        start_date: filter_start_date,
        end_date: filter_end_date
      )
    end

    def admin_permissions_for_person?
      person = current_site.people.find_by(slug: params[:slug])
      if person && current_admin
        ::GobiertoAdmin::GobiertoPeople::PersonPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          person: person
        ).view?
      else
        false
      end
    end

    def resolve_layout
      if action_name == "index" && current_site.departments_available?
        "gobierto_people/layouts/departments"
      else
        "gobierto_people/layouts/application"
      end
    end

  end
end
