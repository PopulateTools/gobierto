# frozen_string_literal: true

module GobiertoParticipation
  class FilteredEventsController < GobiertoParticipation::ApplicationController

    include ::PreviewTokenHelper

    def show
      @event = find_event

      set_events
    end

    def index
      @issues = find_issues
      @scopes = find_scopes

      set_events

      respond_to do |format|
        format.html
        format.js
      end
    end

    private

    def find_event
      base_relation.find_by_slug!(params[:id])
    end

    def base_relation
      @base_relation ||= if valid_preview_token?
                           GobiertoCalendars::Event.in_collections_and_container_type(current_site, "GobiertoParticipation")
                         else
                           GobiertoCalendars::Event.in_collections_and_container_type(current_site, "GobiertoParticipation").published
                         end
    end

    def set_events
      @events = base_relation.sorted.page params[:page]

      if params[:date]
        filter_events_by_date(params[:date])
      elsif @past_events
        @events = @events.past.sorted_backwards
      elsif @events.upcoming.empty?
        @no_upcoming_events = true
        @events = @events.past.sorted_backwards
      else
        @events = @events.upcoming.sorted
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
