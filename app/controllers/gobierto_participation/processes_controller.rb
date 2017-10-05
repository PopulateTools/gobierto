# frozen_string_literal: true

module GobiertoParticipation
  class ProcessesController < GobiertoParticipation::ApplicationController

    include ::PreviewTokenHelper

    helper_method :current_process

    def index
      @processes = current_site.processes.process.open.active
      @groups = current_site.processes.group_process.open.active
    end

    def show
      @process_news = find_process_news
      @process_events = find_process_events
      @activities = [] # TODO: implementation not yet defined
      @process_stages = current_process.stages.active
    end

    private

    def find_process_news
      current_process.news.sort_by(&:created_at).reverse.first(5)
    end

    def find_process_events
      current_process.events.upcoming.order(starts_at: :asc).limit(5)
    end

    def current_process
      @current_process ||= begin
        params[:id] ? processes_scope.find_by_slug!(params[:id]) : nil
      end
    end

    def processes_scope
      valid_preview_token? ? current_site.processes.draft : current_site.processes.active
    end
  end
end
