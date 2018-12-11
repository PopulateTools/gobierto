# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class EventsController < BaseController
      include ::PreviewTokenHelper

      def show
        @event = find_event

        set_events
      end

      def index
        @issues = find_issues

        @issue = find_issue if params[:issue_id]

        set_events

        respond_to do |format|
          format.html
          format.js
        end
      end

      private

      def process_events_scope
        if valid_preview_token?
          current_process.events.sorted
        else
          current_process.events.sorted.published
        end
      end

      def find_event
        process_events_scope.find_by_slug!(params[:id])
      end

      def set_events
        @events = process_events_scope
        @events = @events.with_term(@issue) if @issue

        @events = if params[:date]
                    filter_events_by_date(params[:date]).published
                  elsif @past_events
                    @events.past.sorted_backwards
                  elsif @events.upcoming.empty?
                    @no_upcoming_events = true
                    @events.past.sorted_backwards
                  else
                    @events.upcoming.sorted
                  end

        @events = @events.page params[:page]
        @calendar_events = process_events_scope
      end

      def filter_events_by_date(date)
        @filtering_date = Date.parse(date)
        events = process_events_scope.by_date(@filtering_date)
        events = (@filtering_date >= Time.now ? events.sorted : events.sorted_backwards)
      rescue ArgumentError
        events
      end
    end
  end
end
