# frozen_string_literal: true

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
        PoliticalGroup.find_by!(slug: params[:political_group_slug])
      end
    end
  end
end
