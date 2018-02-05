# frozen_string_literal: true

module GobiertoParticipation
  class NewsController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    def show
      @page = find_single_news
    end

    def index
      @issues = current_site.issues
      @issue = find_issue if params[:issue_id]
      @pages = if @issue
                  # TODO: this is returning both pages and news, but wait until proper refactor
                  GobiertoCms::Page.news_in_collections_and_container(current_site, @issue).sorted.page(params[:page]).active
               else
                 participation_module_news.page(params[:page]).sorted.active
               end
    end

    private

    def find_issue
      current_site.issues.find_by_slug!(params[:issue_id])
    end

    def participation_module_news
      ::GobiertoCms::Page.news_in_collections_and_container_type(current_site, "GobiertoParticipation")
    end

    def find_single_news
      news_scope.find_by_slug!(params[:id])
    end

    def news_scope
      valid_preview_token? ? participation_module_news.draft : participation_module_news.active
    end
  end
end
