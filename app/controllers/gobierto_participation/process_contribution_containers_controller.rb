# frozen_string_literal: true

module GobiertoParticipation
  class ProcessContributionContainersController < GobiertoParticipation::Processes::BaseController
    def index
      @process = find_process
      @contribution_containers = @process.contribution_containers.active
    end

    def show
      @contribution_container = find_contribution_container
      @process = @contribution_container.process
    end

    private

    def find_process
      ::GobiertoParticipation::Process.find_by_slug!(params[:process_id])
    end

    def find_contribution_container
      current_site.contribution_containers.find_by!(slug: params[:id])
    end
  end
end
