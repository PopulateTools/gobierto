module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessPagesController < Processes::BaseController
        def index
          @collection = current_process.news_collection
          @pages = ::GobiertoCms::Page.where(id: @collection.news_in_collection).sorted
        end
      end
    end
  end
end
