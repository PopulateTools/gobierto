# frozen_string_literal: true

module GobiertoParticipation
  class PagesController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    before_action :find_page_by_id_and_redirect

    def show
      @page = find_page
    end

    def index
      @issues = current_site.issues
      @issue = find_issue if params[:issue_id]
      @pages = if @issue
                 GobiertoCms::Page.pages_in_collections_and_container(current_site, @issue).sorted.page(params[:page]).active
               else
                 find_participation_news.page(params[:page]).sorted.page params[:page]
               end
    end

    private

    def find_issue
      current_site.issues.find_by_slug!(params[:issue_id])
    end

    # Load page by ID is necessary to keep the search results page unified and simple
    def find_page_by_id_and_redirect
      if params[:id].present? && params[:id] =~ /\A\d+\z/
        page = current_site.pages.active.find(params[:id])
        redirect_to(gobierto_cms_page_path(page.slug)) && (return false)
      end
    end

    def find_participation_news
      ::GobiertoCms::Page.pages_in_collections_and_container_type(current_site, "GobiertoParticipation").active
    end

    def find_page
      pages_scope.find_by_slug!(params[:id])
    end

    def pages_scope
      valid_preview_token? ? find_participation_news.draft : find_participation_news.active
    end
  end
end
