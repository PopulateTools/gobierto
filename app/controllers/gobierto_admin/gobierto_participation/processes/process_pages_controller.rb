module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessPagesController < Processes::BaseController
        def index
          @collection = current_process.pages_collection
        end
      end
    end
  end
end
