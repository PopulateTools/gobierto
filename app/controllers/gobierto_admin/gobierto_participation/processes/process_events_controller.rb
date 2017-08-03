module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessEventsController < Processes::BaseController
        def index
          @collection = current_process.events_collection
          @events_presenter = GobiertoAdmin::GobiertoCalendars::EventsPresenter.new(@collection)
        end
      end
    end
  end
end
