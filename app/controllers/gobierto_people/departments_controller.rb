# frozen_string_literal: true

module GobiertoPeople
  class DepartmentsController < GobiertoPeople::ApplicationController
    include DatesRangeHelper

    DEFAULT_LIMIT = 10
    before_action :check_active_submodules

    def index
      @departments_count = site_departments.count
      @departments = site_departments.joins(:events).group(:id).order("count(#{ events_table }.id) DESC").limit(DEFAULT_LIMIT)
      @total_events = site_events.with_department.count
      @total_people = site_events.with_department.select(:collection_id).distinct.count
    end

    def show
      @department = site_departments.find_by_slug!(params[:id])
      people = QueryWithEvents.new(relation: @department.people.with_event_attendances,
                                   start_date: filter_start_date,
                                   end_date: filter_end_date)

      interest_groups = QueryWithEvents.new(relation: @department.events.with_interest_group,
                                            start_date: filter_start_date,
                                            end_date: filter_end_date)
      @department_stats = {
        total_people_with_attendances: people.relation.count,
        unique_interest_groups: interest_groups.relation.select(:interest_group_id).distinct.count
      }
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless departments_submodule_active?
    end

    protected

    def site_events
      QueryWithEvents.new(relation: current_site.events,
                                   start_date: filter_start_date,
                                   end_date: filter_end_date).relation
    end

    def site_departments
      current_site.departments
    end

    def events_model
      GobiertoCalendars::Event
    end

    def events_table
      events_model.table_name
    end
  end
end
