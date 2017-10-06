# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class EventsController < BaseController
      include ::PreviewTokenHelper

      def show
        @event = find_event

        set_events
      end

      def index
        @issue = find_issue

        set_events

        respond_to do |format|
          format.html
          format.js
        end
      end

      private

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_participation_events
        ::GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted
      end

      def find_event
        find_participation_events.find_by_slug!(params[:id])
      end

      def set_events
        @events = ::GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted.page params[:page]
        @events = @events.events_in_collections_and_container(current_site, @issue) if @issue

        if params[:date]
          filter_events_by_date(params[:date])
        else
          if @past_events
            @events = @events.past.sorted_backwards
          else
            if @events.upcoming.empty?
              @no_upcoming_events = true
              @events = @events.past.sorted_backwards
            else
              @events = @events.upcoming.sorted
            end
          end
        end
      end

      def filter_events_by_date(date)
        @filtering_date = Date.parse(date)
        @events = @events.by_date(@filtering_date)
        @events = (@filtering_date >= Time.now ? @events.sorted : @events.sorted_backwards)
      rescue ArgumentError
        @events
      end
    end
  end
end
