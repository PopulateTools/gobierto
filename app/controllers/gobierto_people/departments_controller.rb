# frozen_string_literal: true

module GobiertoPeople
  class DepartmentsController < GobiertoPeople::ApplicationController
    before_action :check_active_submodules

    def index
      @departments = @site.departments
      @total_events = events_with_department.count
      @total_people = events_with_department.select(:collection_id).distinct.count
      @events_by_department = transform_id_keys(events_with_department.group(:department_id).order(count: :desc).count, departments_model)
      @people_by_department = transform_id_keys(events_with_department.select(:collection_id).distinct.group(:department_id).order("count_collection_id desc").count, departments_model)

      monthly_columns = [:department_id, "extract(year from starts_at)", "extract(month from starts_at)"]
      @monthly_events_grouped_by_department = transform_id_keys(events_with_department.group(*monthly_columns).count.group_by { |key, _| key[0] }, departments_model)
      @monthly_events_grouped_by_department.transform_values! { |value| base_punchcard_dates.merge(value.to_h.transform_keys { |key| Date.new(key[1], key[2]) }) }
    end

    def show
      @department = @site.departments.find(params[:id])
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless departments_submodule_active?
    end

    protected

    def base_punchcard_dates
      @base_punchcard_dates ||= begin
                                  first_date = events_with_department.order(starts_at: :asc).first.starts_at
                                  last_date = events_with_department.order(starts_at: :asc).last.starts_at
                                  combinations = [*(first_date.year..last_date.year)].product([*(1..12)])
                                  combinations.slice!(0, first_date.month - 1)
                                  combinations.slice!(combinations.length - 12 + last_date.month, 12 - last_date.month)
                                  combinations.map { |combination| [Date.new(*combination), 0] }.to_h
                                end
    end

    def transform_id_keys(hash, model)
      hash.transform_keys! { |id| model.find(id) }
    end

    def events_with_department
      @site.events.where.not(department_id: nil).where("starts_at >= ?", 10.years.ago)
    end

    def events_model
      GobiertoCalendars::Event
    end

    def events_table
      events_model.table_name
    end

    def departments_model
      GobiertoPeople::Department
    end

    def departments_table
      departments_model.table_name
    end
  end
end
