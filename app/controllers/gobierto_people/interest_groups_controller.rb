# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupsController < GobiertoPeople::ApplicationController
    DEFAULT_LIMIT = 10
    before_action :check_active_submodules

    def index
      @interest_groups_count = @site.interest_groups.count
      @interest_groups = @site.interest_groups.joins(:events).group(:id).order("count(#{ events_table }.id) DESC").limit(DEFAULT_LIMIT)
      @total_events = events_with_interest_group.count
    end

    def show
      @interest_group = @site.interest_groups.find_by_slug!(params[:id])
      @total_events = @interest_group.events.count
      @total_people = @interest_group.events.select(:collection_id).distinct.count
    end

    def check_active_submodules
      redirect_to gobierto_people_root_path unless interest_groups_submodule_active?
    end

    protected

    def events_with_interest_group
      @site.events.where.not(interest_group_id: nil)
    end

    def events_model
      GobiertoCalendars::Event
    end

    def events_table
      events_model.table_name
    end
  end
end
