# frozen_string_literal: true

module GobiertoParticipation
  class PagesController < GobiertoParticipation::ApplicationController
    include ::PreviewTokenHelper

    def show
      @page = find_page
    end

    private

    def participation_module_pages
      ::GobiertoCms::Page.pages_in_collections_and_container_type(current_site, "GobiertoParticipation")
    end

    def find_page
      pages_scope.find_by_slug!(params[:id])
    end

    def pages_scope
      valid_preview_token? ? participation_module_pages.draft : participation_module_pages.active
    end
  end
end
