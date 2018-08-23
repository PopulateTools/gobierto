# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessPagesController < Processes::BaseController

        def index
          load_collection
          @pages = ::GobiertoCms::Page.where(id: @collection.news_in_collection).sorted
          @archived_pages = current_site.pages.only_archived.where(id: @collection.news_in_collection).sorted
        end

        private

        def load_collection
          @collection = current_process.news_collection
          @preview_item = @collection
        end

      end
    end
  end
end
