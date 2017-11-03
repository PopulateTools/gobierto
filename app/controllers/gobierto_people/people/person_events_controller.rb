module GobiertoPeople
  module People
    class PersonEventsController < BaseController

      before_action :set_calendar_events, only: [:index]

      def index
        if params[:date]
          @filtering_date = Date.parse(params[:date])
          @events = @person.attending_events.by_date(@filtering_date).sorted.page params[:page]
        else
          @events = @person.attending_events.upcoming.sorted.page params[:page]
        end

        respond_to do |format|
          format.js
          format.html
          format.json do
            render(json: { events: fullcalendar_events } )
          end
        end
      end

      def show
        @event = find_event
        if valid_preview_token? && !manage_event?
          redirect_to(
            gobierto_people_person_path(@event.collection.container.slug),
            alert: t('gobierto_admin.admin_unauthorized')
          ) and return
        end
      end

      private

      def fullcalendar_events
        starts = Time.zone.parse(params[:start])
        ends   = Time.zone.parse(params[:end])
        events = @person.attending_events.published.where('starts_at >= ? AND ends_at <= ?', starts, ends)
        events.map do |event|
          ::GobiertoCalendars::FullcalendarEventSerializer.new(
            event,
            current_site: current_site,
            person_slug: @person.slug
          )
        end
      end

      def find_event
        person_events_scope.find_by!(slug: params[:slug])
      end

      def set_calendar_events
        @calendar_events = @person.attending_events
      end

      def person_events_scope
        valid_preview_token? ? @person.attending_events : @person.attending_events.published
      end

      def manage_event?
        ::GobiertoAdmin::GobiertoCalendars::EventPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          event: @event
        ).view?
      end

    end
  end
end
