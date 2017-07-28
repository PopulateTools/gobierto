module GobiertoParticipation
  class ProcessesController < GobiertoParticipation::ApplicationController

    def index
      @processes = current_site.processes.process
      @groups    = current_site.processes.group_process
    end

    def show
      @process = GobiertoParticipation::Process.find_by!(slug: params[:id])

      @process_news   = find_process_news
      @process_events = find_process_events
      @activities     = [] # TODO: implementation not yet defined
      @process_stages = @process.stages
    end

    private

    def find_person
      people_scope.find_by!(slug: params[:slug])
    end

    def find_process_news
      news_collection ? news_collection.collection_items.limit(5).map { |collection_item| collection_item.item } : []
    end

    def find_process_events
      events_collection ? events_collection.collection_items.limit(5).map { |collection_item| collection_item.item } : []
    end

    def news_collection
      GobiertoCommon::Collection.find_by(container: @process, item_type: 'GobiertoCms::Page')
    end

    def events_collection
      GobiertoCommon::Collection.find_by(container: @process, item_type: 'GobiertoPeople::PersonEvent')
    end

  end
end
