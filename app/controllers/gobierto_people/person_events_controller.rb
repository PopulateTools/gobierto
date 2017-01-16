module GobiertoPeople
  class PersonEventsController < GobiertoPeople::ApplicationController
    include PoliticalGroupsHelper

    def index
      @events = current_site.person_events.upcoming.sorted
      @events = filter_by_date_param if params[:date]
      @people = current_site.people.active.sorted
      @political_groups = get_political_groups
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
