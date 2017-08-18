# frozen_string_literal: true

module GobiertoParticipation
  class IssuesController < GobiertoParticipation::ApplicationController
    def index
      @issues = current_site.issues.alphabetically_sorted
    end

    def show
      @issue = find_issue
      @issue_news = find_issue_news
      @issue_news_updated = find_issue_news_updated
      @issue_events = find_issue_events
      @processes = current_site.processes.process.open
      @groups = current_site.processes.group_process
    end

    private

    def find_issue
      Issue.find_by_slug!(params[:id])
    end

    def find_issue_news
      @issue.extend_news.sort_by(&:created_at).reverse.first(5)
    end

    def find_issue_news_updated
      @issue.extend_news.order(updated_at: :asc).limit(5)
    end

    def find_issue_events
      @issue.extend_events.upcoming.order(starts_at: :asc).limit(5)
    end
  end
end
