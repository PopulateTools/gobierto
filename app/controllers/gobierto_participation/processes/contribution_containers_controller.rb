# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class ContributionContainersController < BaseController
      def index
        @contribution_containers = find_contribution_containers
      end

      def show
        @contribution_container = find_contribution_container
      end

      private

      def find_contribution_container
        find_contribution_containers.find_by!(slug: params[:id])
      end

      def find_contribution_containers
        current_process.contribution_containers.active
      end
    end
  end
end
