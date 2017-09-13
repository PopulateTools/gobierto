# frozen_string_literal: true

module GobiertoParticipation
  class WelcomeController < GobiertoParticipation::ApplicationController
    def index
      @processes = current_site.processes.process
      @issues = current_site.issues.alphabetically_sorted
      @processes_events = find_processes_events
      @participation_news = find_participation_news.page(params[:page])
    end

    private

    def find_processes_events
      current_site.events.upcoming.order(starts_at: :asc).limit(5)
    end

    def find_participation_news
      ::GobiertoCms::Page.pages_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted
    end
  end
end
