# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupsController < GobiertoPeople::ApplicationController
    include DatesRangeHelper

    DEFAULT_LIMIT = 10
    before_action :check_active_submodules

    def index
      interest_groups = QueryWithEvents.new(source: @site.interest_groups,
                                            start_date: filter_start_date,
                                            end_date: filter_end_date)
      @interest_groups_count = interest_groups.count
      @interest_groups = InterestGroupsQuery.new(relation: interest_groups.relation, limit: DEFAULT_LIMIT).results
      @total_events = events_with_interest_group.count
    end

    def show
      @interest_group = @site.interest_groups.find_by_slug!(params[:id])
      events = QueryWithEvents.new(source: @interest_group.events,
                                   start_date: filter_start_date,
                                   end_date: filter_end_date)
      @total_events = events.count
      @total_people = events.select(:collection_id).distinct.count
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless interest_groups_submodule_active?
    end

    protected

    def events_with_interest_group
      QueryWithEvents.new(source: @site.events,
                          start_date: filter_start_date,
                          end_date: filter_end_date,
                          not_null: [:interest_group_id])
    end

    def events_model
      GobiertoCalendars::Event
    end

    def events_table
      events_model.table_name
    end
  end
end
