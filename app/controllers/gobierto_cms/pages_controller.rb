# frozen_string_literal: true

module GobiertoCms
  class PagesController < GobiertoCms::ApplicationController
    include ::PreviewTokenHelper

    before_action :find_page_by_id_and_redirect

    def show
      @section = find_section if params[:slug_section]
      @page = find_page
      if params[:process]
        @process = find_process
        @groups = current_site.processes.group_process
      end

      if @page
        @section_item = find_section_item if params[:slug_section]
        @collection = @page.collection
        @pages = ::GobiertoCms::Page.where(id: @collection.pages_in_collection).active
      elsif @section
        redirect_to gobierto_cms_section_item_path(find_first_page_in_section.slug, slug_section: @section.slug)
      end
    end

    def index
      if params[:slug_section]
        @section = find_section
        redirect_to gobierto_cms_section_item_path(find_first_page_in_section.slug, slug_section: @section.slug)
      else
        @collection = current_site.collections.find_by!(slug: params[:id])
        @pages = ::GobiertoCms::Page.where(id: @collection.pages_in_collection).active
      end
    end

    private

    # Load page by ID is necessary to keep the search results page unified and simple
    def find_page_by_id_and_redirect
      if params[:id].present? && params[:id] =~ /\A\d+\z/
        page = current_site.pages.active.find(params[:id])
        redirect_to(gobierto_cms_page_path(page.slug)) && (return false)
      end
    end

    def find_process
      ::GobiertoParticipation::Process.find_by_slug!(params[:process])
    end

    def find_section
      current_site.sections.find_by!(slug: params[:slug_section])
    end

    def find_section_item
      ::GobiertoCms::SectionItem.find_by!(item: @page, section: @section)
    end

    def find_first_page_in_section
      ::GobiertoCms::Page.first_page_in_section(@section)
    end

    def find_process_news
      @process.news.sort_by_updated_at.limit(5)
    end

    def find_page
      if params[:id]
        pages_scope.find_by!(slug: params[:id])
      end
    end

    def pages_scope
      valid_preview_token? ? current_site.pages.draft : current_site.pages.active
    end
  end
end
