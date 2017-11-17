module GobiertoAdmin
  module GobiertoCalendars
    class CollectionsController < BaseController
      def index
        @collections = current_site.collections.by_item_type('GobiertoCalendars::Event')
        @events = current_site.events.sort_by_updated_at.limit(10)
      end
    end
  end
end
