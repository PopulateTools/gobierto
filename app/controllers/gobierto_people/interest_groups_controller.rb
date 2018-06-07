# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupsController < GobiertoPeople::ApplicationController
    before_action :check_active_submodules

    def index
      @interest_groups_count = @site.interest_groups.count
      @interest_groups = @site.interest_groups.limit(default_limit)
      @total_events = events_with_interest_group.count
      @events_by_interest_group = transform_id_keys(events_with_interest_group.group(:interest_group_id).order(count: :desc).limit(default_limit).count, interest_groups_model)
    end

    def show
      @interest_group = @site.interest_groups.find(params[:id])
      @total_events = @interest_group.events.count
      @total_people = @interest_group.events.select(:collection_id).distinct.count
      @events_by_department = transform_id_keys(@interest_group.events.person_events.group(:department_id).order(count: :desc).count, department_model)
      @events_by_people = transform_id_keys(@interest_group.events.person_events.group(:container_id).order(count: :desc).count, people_model)
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless interest_groups_submodule_active?
    end

    protected

    def transform_id_keys(hash, model)
      hash.transform_keys! { |id| model.find(id) }
    end

    def events_with_interest_group
      @site.events.where.not(interest_group_id: nil).where("starts_at >= ?", 10.years.ago)
    end

    def default_limit
      10
    end

    def events_model
      GobiertoCalendars::Event
    end

    def events_table
      events_model.table_name
    end

    def interest_groups_model
      GobiertoPeople::InterestGroup
    end

    def interest_groups_table
      interest_groups_model.table_name
    end

    def people_model
      GobiertoPeople::Person
    end

    def department_model
      GobiertoPeople::Department
    end
  end
end
