# frozen_string_literal: true

module GobiertoParticipation
  class ProcessesController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    helper_method :current_process, :process_stage_path

    def index
      @processes = current_site.processes.process.active
      @groups = CollectionDecorator.new(current_site.processes.group_process.active, decorator: GobiertoParticipation::ProcessDecorator)
    end

    def show
      @process = current_process
      @process_news = find_process_news
      @process_events = find_process_events
      @process_activities = find_process_activities
      @process_stages = current_process.stages.published
    end

    private

    def find_process_news
      current_process.news.sort_by_published_on.first(5)
    end

    def find_process_events
      current_process.events.published.first(5)
    end

    def current_process
      @current_process ||= begin
        params[:id] ? processes_scope.find_by_slug!(params[:id]) : nil
      end
    end

    def processes_scope
      valid_preview_token? ? current_site.processes.draft : current_site.processes.active
    end

    def find_process_activities
      ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_process(current_process).sorted.limit(5).includes(:subject, :author, :recipient))
    end

    def process_stage_path(stage)
      stage.process_stage_path
    end
  end
end
