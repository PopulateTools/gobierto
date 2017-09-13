# frozen_string_literal: true

module GobiertoParticipation
  class WelcomeController < GobiertoParticipation::ApplicationController
    def index
      @processes = current_site.processes.process
      @issues = current_site.issues.alphabetically_sorted
      @processes_events = find_processes_events
      @processes_news = find_processes_news
    end

    private

    def find_processes_events
      current_site.events.upcoming.order(starts_at: :asc).limit(5)
    end

    def find_processes_news
      current_site.pages.sort_by(&:created_at).reverse.first(5)
    end
  end
end
