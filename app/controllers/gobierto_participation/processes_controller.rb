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
      @process = current_process
      @process_news = find_process_news
      @process_events = find_process_events
      @process_activities = find_process_activities
      @process_stages = current_process.stages
    end

    private

    def find_person
      people_scope.find_by!(slug: params[:slug])
    end

    def find_process_news
      current_process.news.sort_by(&:created_at).reverse.first(5)
      # TODO: rewrite using Rails chainable scopes. Maybe something like this:
      # @process.news.upcoming.order(created_at: :desc).limit(5)
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
      valid_preview_token? ? current_site.processes : current_site.processes.active
    end

    def find_process_activities
      # TODO: Filter activities
      ActivityCollectionDecorator.new(Activity.in_site(current_site).participation.sorted.limit(5).includes(:subject, :author, :recipient).page(params[:page]))
    end
  end
end
