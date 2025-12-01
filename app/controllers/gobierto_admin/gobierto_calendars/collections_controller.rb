module GobiertoAdmin
  module GobiertoCalendars
    class CollectionsController < BaseController
      before_action :check_permissions!

      def index
        @collections = current_site.collections.by_item_type('GobiertoCalendars::Event')

        # Filter out collections with Person containers if admin doesn't have GobiertoPeople permissions
        unless current_admin.module_allowed?("GobiertoPeople", current_site)
          @collections = @collections.where.not(container_type: "GobiertoPeople::Person")
        end

        @events = current_site.events.sort_by_updated_at.limit(10)
      end

      private

      def check_permissions!
        raise_module_not_allowed unless current_admin.can_edit_calendars?
      end
    end
  end
end
