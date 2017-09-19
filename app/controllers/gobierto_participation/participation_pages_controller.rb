# frozen_string_literal: true

module GobiertoParticipation
  class ParticipationPagesController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    before_action :find_page_by_id_and_redirect

    def show
      @new = find_new
    end

    def index
      @news = find_participation_news.page(params[:page])
    end

    private

    # Load page by ID is necessary to keep the search results page unified and simple
    def find_page_by_id_and_redirect
      if params[:id].present? && params[:id] =~ /\A\d+\z/
        page = current_site.pages.active.find(params[:id])
        redirect_to gobierto_cms_page_path(page.slug) and return false
      end
    end

    def find_participation_news
      ::GobiertoCms::Page.pages_in_collections_and_container_type(current_site, "GobiertoParticipation").sorted
    end

    def find_new
      pages_scope.find_by_slug!(params[:id])
    end

    def pages_scope
      valid_preview_token? ? find_participation_news.draft : find_participation_news.active
    end
  end
end
