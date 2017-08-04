module GobiertoParticipation
  class EventsController < GobiertoParticipation::ApplicationController

    def index
      @container = find_container(params[:container_type], params[:container_id])
      @events = @container.events.upcoming.page params[:page]
      @calendar_events = @container.events
    end

    def show
      @container = find_container(params[:container_type], params[:container_id])

      @event = find_event
      @calendar_events = @container.events
    end

    private

    def find_event
      GobiertoCalendars::Event.find_by!(slug: params[:id])
    end

    def find_container(container_type, container_id)
      return unless container_type && container_id
      container_klass = GobiertoCommon::ActsAsCollectionContainer.container_klass_for[container_type]
      container_klass ? container_klass.find(container_id) : nil
    end

  end
end
