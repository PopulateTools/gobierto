# frozen_string_literal: true

module GobiertoParticipation
  class IssuesController < GobiertoParticipation::ApplicationController
    def index
      @issues = current_site.issues.alphabetically_sorted
    end

    def show
      @issue = find_issue
      @issue_news = find_issue_news
      @issue_notifications = find_issue_notifications
      @issue_events = find_issue_events
      @processes = current_site.processes.process.where(issue: @issue).active
      @groups = current_site.processes.group_process.where(issue: @issue)
    end

    private

    def find_issue
      current_site.issues.find_by!(slug: params[:id])
    end

    def find_issue_news
      @issue.news.sort_by(&:created_at).reverse.first(5)
      # TODO: rewrite using Rails chainable scopes. Maybe something like this:
      # @process.news.upcoming.order(created_at: :desc).limit(5)
    end

    def find_issue_notifications
      ActivityCollectionDecorator.new(Activity.in_site(current_site).activities_in_issue(@issue).sorted.includes(:subject, :author, :recipient).page(params[:page]))
    end

    def find_issue_events
      @issue.events.upcoming.order(starts_at: :asc).limit(5)
    end
  end
end
