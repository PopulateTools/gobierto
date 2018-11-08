# frozen_string_literal: true

module GobiertoParticipation
  class IssuesController < GobiertoParticipation::ApplicationController
    def index
      @issues = find_issues
    end

    def show
      @issue = find_issue
      @issue_news = find_issue_news
      @issue_notifications = find_issue_notifications
      @issue_events = find_issue_events
      @processes = current_site.processes.process.where(issue: @issue).active
      @groups = CollectionDecorator.new(find_groups, decorator: GobiertoParticipation::ProcessDecorator)
    end

    private

    def find_groups
      current_site.processes.group_process.where(issue: @issue).active
    end

    def find_issue
      ProcessTermDecorator.new(current_site.issues.find_by!(slug: params[:id]))
    end

    def find_issue_news
      @issue.active_news.limit(5)
    end

    def find_issue_notifications
      ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_process(@issue.processes).sorted.limit(5).includes(:subject, :author, :recipient))
    end

    def find_issue_events
      @issue.events.published.upcoming.order(starts_at: :asc).limit(5)
    end
  end
end
