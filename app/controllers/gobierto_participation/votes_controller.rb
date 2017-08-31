# frozen_string_literal: true

module GobiertoParticipation
  class VotesController < GobiertoParticipation::ApplicationController
    def new
      @votable = find_votable
      vote_policy = VotePolicy.new(current_user, votable)
      raise Errors::NotAuthorized unless vote_policy.create?

      @vote_form = VoteForm.new
    end

    def create
      params[:id] = params[:process_contribution_id]

      votable = find_votable

      vote_policy = VotePolicy.new(current_user, votable)
      raise Errors::NotAuthorized unless vote_policy.create?

      @vote_form = VoteForm.new(vote_params.merge(site_id: current_site.id,
                                                  user_id: current_user.id,
                                                  votable_type: find_votable.class,
                                                  votable_id: find_votable.id))

      respond_to do |format|
        format.js
      end
    end

    private

    def default_activity_params
      { ip: remote_ip, author: current_admin, site_id: current_site.id }
    end

    def vote_params
      params.permit(
        vote_weight: 1
      )
    end

    def find_votable
      current_site.contributions.find_by!(slug: params[:id])
    end
  end
end
