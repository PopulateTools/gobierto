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
        @scope = current_site.scopes.find_by_slug!(params[:scope_id])
      end
    end

    def participation_module_news
      if @issue
        GobiertoCms::Page.pages_in_collections_and_container(current_site, @issue)
      elsif @scope
        GobiertoCms::Page.pages_in_collections_and_container(current_site, @scope)
      else
        ::GobiertoCms::Page.news_in_collections_and_container_type(current_site, "GobiertoParticipation")
      end
    end
  end
end
