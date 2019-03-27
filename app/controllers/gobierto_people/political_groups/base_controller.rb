# frozen_string_literal: true

module GobiertoPeople
  module PoliticalGroups
    class BaseController < GobiertoPeople::ApplicationController
      include PoliticalGroupsHelper

      before_action :set_political_group

      private

      def set_political_group
        @political_group = PersonTermDecorator.new(find_political_group)
      end

      protected

      def find_political_group
        current_site.political_groups.find_by!(slug: params[:political_group_slug])
      end
    end
  end
end
