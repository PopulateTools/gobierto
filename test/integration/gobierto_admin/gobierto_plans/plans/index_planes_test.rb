# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class IndexPlanesTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_contribution_containers_path(process_id: process)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:sport_city_process)
      end

      def contribution_container
        @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
      end
    end
  end
end
