module GobiertoParticipation
  class PagesController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    before_action :find_page_by_id_and_redirect

    def show
      @process = find_process if params[:process_id]
      @page = find_page
      @groups = current_site.processes.group_process
    end

    def index
      # TODO: params['from'] == 'participation' Add to process layout hidden_field
      @issues = current_site.issues
      @process = find_process if params[:process_id]
      @pages = if params[:process]
                 find_process_news.page(params[:page])
               else
                 current_site.pages.active.page(params[:page])
               end
    end

    private

    # Load page by ID is necessary to keep the search results page unified and simple
    def find_page_by_id_and_redirect
      if params[:id].present? && params[:id] =~ /\A\d+\z/
        page = current_site.pages.active.find(params[:id])
        redirect_to gobierto_cms_page_path(page.slug) and return false
      end
    end

    def find_process
      ::GobiertoParticipation::Process.find_by_slug!(params[:process_id])
    end

    def find_process_news
      @process.news.sort_by_updated_at(5)
    end

    def find_page
      pages_scope.find_by_slug!(params[:id])
    end

    def pages_scope
      valid_preview_token? ? current_site.pages.draft : current_site.pages.active
    end
  end
end
