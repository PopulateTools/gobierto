module GobiertoPeople
  module PoliticalGroups
    class BaseController < GobiertoPeople::ApplicationController
      include PoliticalGroupsHelper

      before_action :set_political_group

      private

      def set_political_group
        @political_group = find_political_group
      end

      protected

      def find_political_group
        PoliticalGroup.find(params[:political_group_id])
      end
    end
  end
end
