# frozen_string_literal: true

module GobiertoParticipation
  class ScopesController < GobiertoParticipation::ApplicationController
    def index
      @scopes = find_scopes
    end

    def show
      @scope = find_scope
      @scope_news = find_scope_news
      @scope_notifications = find_scope_notifications
      @scope_events = find_scope_events
      @processes = base_relation.process
      @groups = CollectionDecorator.new(find_groups, decorator: GobiertoParticipation::ProcessDecorator)
    end

    private

    def find_groups
      base_relation.group_process
    end

    def find_scope
      ProcessTermDecorator.new(current_site.scopes.find_by_slug!(params[:id]))
    end

    def find_scope_news
      @scope.active_news.limit(5)
    end

    def find_scope_notifications
      ActivityCollectionDecorator.new(Activity.in_site(current_site)
                                 .no_admin
                                 .in_process(@scope.processes.open_process)
                                 .sorted
                                 .limit(5)
                                 .includes(:subject, :author, :recipient))
    end

    def find_scope_events
      @scope.events.published.upcoming.order(starts_at: :asc).limit(5)
    end

    def base_relation
      current_site.processes.active.available_for_user(current_user).where(scope: @scope)
    end
  end
end
