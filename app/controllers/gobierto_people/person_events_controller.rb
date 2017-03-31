module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      @political_groups = get_political_groups

      set_events
      set_calendar_events
      set_people

      respond_to do |format|
        format.html
        format.json { render json: @events }
        format.csv  { render csv: GobiertoExports::CSVRenderer.new(@events).to_csv, filename: 'events' }
      end
    end

    private

    def set_events
      @events = current_site.person_events.sorted
      @events = filter_by_date_param if params[:date]
      @events = @events.by_person_category(@person_category) if @person_category
      @events = @events.by_person_party(@person_party) if @person_party

      if @past_events
        @events = @events.past
      else
        if @events.upcoming.empty?
          @no_upcoming_events = true
          @events = @events.past
        else
          @events = @events.upcoming
        end
      end
    end

    def set_calendar_events
      @calendar_events = current_site.person_events.within_range(calendar_date_range)
      @calendar_events = @calendar_events.by_person_category(@person_category) if @person_category
      @calendar_events = @calendar_events.by_person_party(@person_party) if @person_party
    end

    def set_people
      @people = current_site.people.active.sorted
      @people = @people.send(Person.categories.key(@person_category)) if @person_category
      @people = @people.send(Person.parties.key(@person_party)) if @person_party
    end

    def filter_by_date_param
      @filtering_date = Date.parse(params[:date])

      @events.by_date(@filtering_date)
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
