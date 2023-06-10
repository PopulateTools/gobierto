module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper
    include PeopleClassificationHelper
    include DatesRangeHelper

    before_action :check_active_submodules

    def index
      set_events
      render_404 and return if params[:page].present? && @events.empty?

      set_calendar_events
      set_people
      set_present_groups_with_published_activities
      @political_groups = get_political_groups

      respond_to do |format|
        format.html
        format.js
        format.json { render json: @events }
        format.csv  { render csv: GobiertoExports::CSVRenderer.new(@events).to_csv, filename: 'events' }
      end
    end

    private

    def check_active_submodules
      if !agendas_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

    def set_events
      @events = GobiertoCalendars::Event.by_site(current_site).
        person_events.
        published.
        includes(:collection, :locations).
        page params[:page]
      @events = @events.by_person_category(@person_category) if @person_category
      @events = @events.by_person_party(@person_party) if @person_party

      if params[:date]
        filter_events_by_date(params[:date])
      else
        if @past_events
          @events = @events.past.sorted_backwards
        else
          if @events.upcoming.empty?
            @no_upcoming_events = true
            @events = @events.past.sorted_backwards
          else
            @events = @events.upcoming.sorted
          end
        end
      end
    end

    def set_calendar_events
      @calendar_events = GobiertoCalendars::Event.by_site(current_site).person_events.published.within_range(calendar_date_range)
      @calendar_events = @calendar_events.by_person_category(@person_category) if @person_category
      @calendar_events = @calendar_events.by_person_party(@person_party) if @person_party
    rescue Date::Error
      raise Errors::InvalidParameters
    end

    def set_people
      @people = current_site.people.includes(:historical_charges).active.sorted
      @people = @people.send(Person.categories.key(@person_category)) if @person_category
      @people = @people.send(Person.parties.key(@person_party)) if @person_party
      @people = CollectionDecorator.new(@people, decorator: PersonDecorator)
    end

    def filter_events_by_date(date)
      @filtering_date = Date.parse(date)
      @events = @events.by_date(@filtering_date)
      @events = (@filtering_date >= Time.now ? @events.sorted : @events.sorted_backwards)
    rescue ArgumentError
      @events
    end

    def calendar_date_range
      if params[:start_date]
        (Date.parse(params[:start_date]).at_beginning_of_month.at_beginning_of_week)..(Date.parse(params[:start_date]).at_end_of_month.at_end_of_week)
      else
        (Time.zone.now.at_beginning_of_month.at_beginning_of_week)..(Time.zone.now.at_end_of_month.at_end_of_week)
      end
    end
  end
end
