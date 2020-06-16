module GobiertoPeople
  module PoliticalGroups
    class PeopleController < BaseController

      include PeopleClassificationHelper
      include DatesRangeHelper

      def index
        @people = CollectionDecorator.new(
          @political_group.people.includes(:historical_charges).by_site(current_site).active.sorted,
          decorator: GobiertoPeople::PersonDecorator
        )
        @political_groups = get_political_groups
        set_present_groups
      end
    end
  end
end
