# frozen_string_literal: true

module GobiertoParticipation
  class NewsController < GobiertoParticipation::ApplicationController
    before_action :load_issue, :load_scope

    def index
      @issues = find_issues
      @pages = participation_module_news.sorted.active.page(params[:page])
    end

    private

    def load_issue
      if params[:issue_id]
        @issue = find_issue
      end
    end

    def load_scope
      if params[:scope_id]
        @scope = find_scope
      end
    end

    def participation_module_news
      if @issue
        @issue.news
      elsif @scope
        @scope.news
      else
        ProcessCollectionDecorator.new(current_site.pages, item_type: "GobiertoCms::News").in_participation_module.active
      end
    end
  end
end
