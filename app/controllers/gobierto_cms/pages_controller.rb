# frozen_string_literal: true

module GobiertoCms
  class PagesController < GobiertoCms::ApplicationController
    before_action :find_page_by_id_and_redirect

    def show
      @page = find_page
    end

    private

    # Load page by ID is necessary to keep the search results page unified and simple
    def find_page_by_id_and_redirect
      if params[:id].present? && params[:id] =~ /\A\d+\z/
        page = current_site.pages.active.find(params[:id])
        redirect_to(gobierto_cms_page_path(page.slug)) && (return false)
      end
    end

    def find_page
      current_site.pages.active.find_by!(slug: params[:id])
    end
  end
end
