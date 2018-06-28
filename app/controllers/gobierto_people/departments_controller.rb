# frozen_string_literal: true

module GobiertoPeople
  class DepartmentsController < GobiertoPeople::ApplicationController
    include DatesRangeHelper

    DEFAULT_LIMIT = 10
    before_action :check_active_submodules

    def index
      @departments = QueryWithEvents.new(
        source: site_departments,
        start_date: filter_start_date,
        end_date: filter_end_date
      )
      @departments_count = @departments.count

      @total_events = QueryWithEvents.new(
        source: current_site.event_attendances,
        start_date: filter_start_date,
        end_date: filter_end_date,
        not_null: [:department_id]
      ).count

      @total_people = site_events.with_department.select(:collection_id).distinct.count
    end

    def show
      @department = site_departments.find_by_slug!(params[:id])
      people = QueryWithEvents.new(source: @department.people.with_event_attendances,
                                   start_date: filter_start_date,
                                   end_date: filter_end_date)

      interest_groups = QueryWithEvents.new(source: @department.events,
                                            start_date: filter_start_date,
                                            end_date: filter_end_date)
      @department_stats = {
        total_people_with_attendances: people.count,
        unique_interest_groups: interest_groups.select(:interest_group_id).distinct.count
      }
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless departments_submodule_active?
    end

    protected

    def site_events
      QueryWithEvents.new(source: current_site.events,
                          start_date: filter_start_date,
                          end_date: filter_end_date)
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
