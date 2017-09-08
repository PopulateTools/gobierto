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
                                                  user_id: current_user.id))

      @vote_form.save

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
        :vote_weight,
        :votable_id,
        :votable_type
      )
    end

    def find_votable
      if params[:votable_type] == "GobiertoParticipation::Contribution"
        current_site.contributions.find_by!(id: params[:votable_id])
      elsif params[:votable_type] == "GobiertoParticipation::Comment"
        current_site.comments.find_by!(id: params[:votable_id])
      end
    end
  end
end
