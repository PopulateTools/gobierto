# frozen_string_literal: true

module GobiertoParticipation
  class ProcessesController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    helper_method :current_process, :process_stage_path

    def index
      @processes = CollectionDecorator.new(base_relation.process, decorator: ProcessDecorator)
      @groups = CollectionDecorator.new(base_relation.group_process, decorator: ProcessDecorator)
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
      @current_process ||= params[:id] ? ProcessDecorator.new(processes_scope.find_by_slug!(params[:id])) : nil
    end

    def processes_scope
      valid_preview_token? ? current_site.processes.draft : base_relation
    end

    def find_process_activities
      ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_process(current_process).sorted.limit(5).includes(:subject, :author, :recipient))
    end

    def base_relation
      current_site.processes.active.available_for_user(current_user)
    end

    def process_stage_path(stage)
      stage.process_stage_path
    end
  end
end
