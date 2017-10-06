# frozen_string_literal: true

module GobiertoParticipation
  class ProcessContributionsController < GobiertoParticipation::Processes::BaseController
    def show
      @contribution = find_contribution
      @process = @contribution.contribution_container.process
      @comment_form = CommentForm.new(site_id: current_site.id)

      respond_to do |format|
        format.js
      end
    end

    private

    def find_process
      ::GobiertoParticipation::Process.find_by_slug!(params[:process_id])
    end

    def find_contribution
      current_site.contributions.find_by!(slug: params[:id])
    end
  end
end
