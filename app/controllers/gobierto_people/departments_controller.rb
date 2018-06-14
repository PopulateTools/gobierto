# frozen_string_literal: true

module GobiertoPeople
  class DepartmentsController < GobiertoPeople::ApplicationController
    DEFAULT_LIMIT = 10
    before_action :check_active_submodules

    def index
      @departments_count = @site.departments.count
      @departments = @site.departments.joins(:events).group(:id).order("count(#{ events_table }.id) DESC").limit(DEFAULT_LIMIT)
      @total_events = events_with_department.count
      @total_people = events_with_department.select(:collection_id).distinct.count
    end

    def show
      @department = @site.departments.find_by_slug!(params[:id])
      @total_events = @department.events.count
      @total_people = @department.events.select(:collection_id).distinct.count
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless departments_submodule_active?
    end

    protected

    def events_with_department
      @site.events.where.not(department_id: nil)
    end

    def events_model
      GobiertoCalendars::Event
    end

    def events_table
      events_model.table_name
    end
  end
end
