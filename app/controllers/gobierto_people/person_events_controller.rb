module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      @events = current_site.person_events.upcoming.sorted
      @events = filter_by_date_param if params[:date]
      @calendar_events = current_site.person_events.for_month_calendar(calendar_date_range)
      @people = current_site.people.active.sorted
      @political_groups = get_political_groups

      respond_to do |format|
        format.html
        format.json { render json: @events }
        format.csv  { render csv: GobiertoExports::CSVRenderer.new(@events).to_csv, filename: 'events' }
      end
    end

    private

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
