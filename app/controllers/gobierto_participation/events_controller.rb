module GobiertoParticipation
  class EventsController < GobiertoParticipation::ApplicationController

    def index
      set_container
      set_events
    end

    def show
      set_container

      @event = find_event
      @calendar_events = @container.events
    end

    private

    def set_events
      if params[:date]
        @events = find_events_by_date params[:date]
      else
        @events = @container.events.upcoming.sorted.page params[:page]
      end

      @calendar_events = @container.events
    end

    def find_event
      current_site.events.find_by!(slug: params[:id])
    end

    def find_container(container_type, container_id)
      return unless container_type && container_id
      container_klass = GobiertoCommon::ActsAsCollectionContainer.container_klass_for[container_type]
      container_klass ? container_klass.find(container_id) : nil
    end

    def set_container
      if params[:container_type] && params[:container_id]
        container_klass = GobiertoCommon::ActsAsCollectionContainer.container_klass_for[params[:container_type]]
        @container = container_klass ? container_klass.find(params[:container_id]) : nil
      end
    end

    def find_events_by_date(date)
      @filtering_date = Date.parse(date)
      events = @container.events.by_date(@filtering_date)
      events = (@filtering_date >= Time.now ? events.sorted : events.sorted_backwards)
      events.page params[:page]
    end

  end
end
