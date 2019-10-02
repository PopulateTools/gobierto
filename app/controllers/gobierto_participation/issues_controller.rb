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
      @processes = base_relation.process
      @groups = CollectionDecorator.new(find_groups, decorator: GobiertoParticipation::ProcessDecorator)
    end

    private

    def find_groups
      base_relation.group_process
    end

    def find_issue
      ProcessTermDecorator.new(current_site.issues.find_by!(slug: params[:id]))
    end

    def find_issue_news
      @issue.active_news.limit(5)
    end

    def find_issue_notifications
      ActivityCollectionDecorator.new(Activity.in_site(current_site).no_admin.in_process(@issue.processes.public_process).sorted.limit(5).includes(:subject, :author, :recipient))
    end

    def find_issue_events
      @issue.events.published.upcoming.order(starts_at: :asc).limit(5)
    end

    def base_relation
      current_site.processes.active.available_for_user(current_user).where(issue: @issue)
    end
  end
end
