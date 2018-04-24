# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessEventsController < Processes::BaseController
        def index
          @collection = current_process.events_collection
          @events_presenter = GobiertoAdmin::GobiertoCalendars::EventsPresenter.new(@collection)

          @events = ::GobiertoCalendars::Event.where(id: @collection.events_in_collection)
                                              .sorted_backwards
                                              .page(params[:events_page])
          @archived_events = current_site.events
                                          .only_archived.where(collection_id: @collection.id)
                                          .sorted
                                          .page(params[:archived_events_page])
        end
      end
    end
  end
end
