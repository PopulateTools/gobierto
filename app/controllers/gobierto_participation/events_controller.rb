# frozen_string_literal: true

module GobiertoParticipation
  class EventsController < GobiertoParticipation::ApplicationController

    include ::PreviewTokenHelper

    def index
      @issue = find_issue if params[:issue_id]
      @issues = find_issues

      container_events
      set_events

      @calendar_events = @container_events
    end

    def show
      container_events

      @event = participation_events_scope.find_by!(slug: params[:id])
      @calendar_events = @container_events
    end

    private

    def set_events
      @events = if params[:date]
                  find_events_by_date params[:date]
                else
                  if @past_events
                    @container_events.past.sorted_backwards.page params[:page]
                  else
                    if @issue
                      GobiertoCalendars::Event.events_in_collections_and_container(current_site, @issue).page(params[:page]).upcoming.sorted.page params[:page]
                    else
                      @container_events.upcoming.sorted.page params[:page]
                    end
                  end
                end

      @calendar_events = @container_events
    end

    def container_events
      @container_events = GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation")
    end

    def participation_events_scope
      valid_preview_token? ? current_site.events : current_site.events.published
    end

    def find_events_by_date(date)
      @filtering_date = Date.parse(date)
      events = @container_events.by_date(@filtering_date)
      events = (@filtering_date >= Time.now ? events.sorted : events.sorted_backwards)
      events.page params[:page]
    end
  end
end
