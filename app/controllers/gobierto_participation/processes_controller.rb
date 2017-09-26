# frozen_string_literal: true

module GobiertoParticipation
  class ProcessesController < GobiertoParticipation::ApplicationController

    include ::PreviewTokenHelper

    helper_method :current_process

    def index
      @processes = current_site.processes.process.active
      @groups = current_site.processes.group_process.active
    end

    def show
      @process_news   = find_process_news
      @process_events = find_process_events
      @activities     = [] # TODO: implementation not yet defined
      @process_stages = current_process.stages.active
    end

    private

    def find_person
      people_scope.find_by!(slug: params[:slug])
    end

    def find_process_news
      current_process.extend_news.active
    end

    def find_process_events
      current_process.extend_events.published
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
