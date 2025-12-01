module GobiertoAdmin
  module GobiertoCalendars
    class CollectionsController < BaseController
      before_action :check_permissions!

      def index
        @collections = current_site.collections.by_item_type('GobiertoCalendars::Event')
        @events = current_site.events.sort_by_updated_at.limit(10)
      end

      private

      def check_permissions!
        raise_module_not_allowed unless current_admin.can_edit_calendars?
      end
    end
  end
end
