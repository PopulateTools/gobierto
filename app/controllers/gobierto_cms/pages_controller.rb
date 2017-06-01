module GobiertoCms
  class PagesController < GobiertoCms::ApplicationController

    include ::PreviewTokenHelper

    before_action :find_page_by_id_and_redirect

    def show
      @page = find_page
    end

    private

    # Load page by ID is necessary to keep the search results page unified and simple
    def find_page_by_id_and_redirect
      if params[:id].present? && params[:id] =~ /\A\d+\z/
        page = current_site.pages.active.find(params[:id])
        redirect_to gobierto_cms_page_path(page.slug) and return false
      end
    end

    def find_page
      pages_scope.find_by_slug!(params[:id])
    end

    def pages_scope
      valid_preview_token? ? current_site.pages.draft : current_site.pages.active
    end

  end
end
