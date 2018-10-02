# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessEventsController < Processes::BaseController

        def index
          load_collection
          @events_presenter = GobiertoAdmin::GobiertoCalendars::EventsPresenter.new(@collection)
          load_events
          load_archived_events
        end

        private

        def load_collection
          @collection = current_process.events_collection
          @preview_item = @collection
        end

        def load_events
          @events = ::GobiertoCalendars::Event.where(id: @collection.events_in_collection)
                                              .sorted_backwards
                                              .page(params[:events_page])
                                              .per(::GobiertoCalendars::Event::ADMIN_PAGE_SIZE)
        end

        def load_archived_events
          @archived_events = current_site.events
                                         .only_archived.where(collection_id: @collection.id)
                                         .sorted
                                         .page(params[:archived_events_page])
                                         .per(::GobiertoCalendars::Event::ADMIN_PAGE_SIZE)
        end

      end
    end
  end
end
