module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      if params[:date]
        @events = filter_by_date_param
        calendar_date_range = (Date.parse(params[:date]).at_beginning_of_month - 1.week)..(Date.parse(params[:date]).at_end_of_month + 1.week)
      else
        @events = current_site.person_events.upcoming.sorted
        calendar_date_range = (Time.zone.now.at_beginning_of_month - 1.week)..(Time.zone.now.at_end_of_month + 1.week)
      end
      
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
  end
end
