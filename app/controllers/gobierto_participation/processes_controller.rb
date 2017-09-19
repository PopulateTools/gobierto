module GobiertoParticipation
  class ProcessesController < GobiertoParticipation::ApplicationController

    def index
      @processes = current_site.processes.open
      @groups = current_site.processes.group_process
    end

    def show
      @process = GobiertoParticipation::Process.find_by!(slug: params[:id])
      @process_news   = find_process_news
      @process_events = find_process_events
      @activities     = [] # TODO: implementation not yet defined
      @process_stages = @process.stages
    end

    private

    def find_person
      people_scope.find_by!(slug: params[:slug])
    end

    def find_process_news
      @process.extend_news
      # TODO: rewrite using Rails chainable scopes. Maybe something like this:
      # @process.news.upcoming.order(created_at: :desc).limit(5)
    end

    def find_process_events
      @process.extend_events
    end

  end
end
