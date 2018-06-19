# frozen_string_literal: true

module GobiertoPeople
  class DepartmentsController < GobiertoPeople::ApplicationController
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
      @department_stats = {
        total_people_with_attendances: @department.people.with_event_attendances.count,
        unique_interest_groups: @department.events.with_interest_group.select(:interest_group_id).distinct.count
      }
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless departments_submodule_active?
    end

    protected

    def site_events
      current_site.events
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
