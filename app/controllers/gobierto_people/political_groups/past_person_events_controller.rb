module GobiertoPeople
  module PoliticalGroups
    class PastPersonEventsController < BaseController
      def index
        @events = @political_group.events.by_site(current_site).past.sorted
        @people = current_site.people.active.sorted
        @political_groups = get_political_groups
      end
    end
  end
end
