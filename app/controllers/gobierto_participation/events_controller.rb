# frozen_string_literal: true

module GobiertoParticipation
  class EventsController < GobiertoParticipation::ApplicationController
    def index
      @issue = find_issue if params[:issue_id]
      @issues = current_site.issues

      container_events
      set_events

      @calendar_events = @container_events
    end

    def show
      container_events

      @event = find_event
      @calendar_events = @container_events
    end

    private

    def find_issue
      current_site.issues.find_by_slug!(params[:issue_id])
    end

    def set_events
      @events = if params[:date]
                  find_events_by_date params[:date]
                else
                  if @issue
                    GobiertoCalendars::Event.events_in_collections_and_container(current_site, @issue).page(params[:page]).upcoming.sorted.page params[:page]
                  else
                    @container_events.upcoming.sorted.page params[:page]
                  end
                end

      @calendar_events = @container_events
    end

    def find_event
      current_site.events.published.find_by!(slug: params[:id])
    end

    def container_events
      module_events = GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation")
      processes_events = GobiertoCalendars::Event.events_in_collections_and_container_type(current_site, "GobiertoParticipation::Process")

      @container_events = module_events.merge(processes_events)
    end

    def find_events_by_date(date)
      @filtering_date = Date.parse(date)
      events = @container_events.by_date(@filtering_date)
      events = (@filtering_date >= Time.now ? events.sorted : events.sorted_backwards)
      events.page params[:page]
    end
  end
end
