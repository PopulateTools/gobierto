# frozen_string_literal: true

module GobiertoParticipation
  class VotesController < GobiertoParticipation::ApplicationController
    include User::VerificationHelper

    before_action(only: [:new, :create, :destroy]) { verify_user_in!(current_site) if current_contribution_container.visibility_user_level == "verified" }

    def new
      @votable = find_votable
      vote_policy = VotePolicy.new(current_user)
      raise Errors::NotAuthorized unless vote_policy.create?

      @vote_form = VoteForm.new
    end

    def create
      @votable = find_votable

      if @votable.voted_by_user?(current_user)
        vote = current_user.votes.find_by!(votable: @votable)
        vote.destroy
      end

      vote_policy = VotePolicy.new(current_user)
      raise Errors::NotAuthorized unless vote_policy.create?

      @vote_form = VoteForm.new(vote_params.merge(site_id: current_site.id,
                                                  user_id: current_user.id))

      if @vote_form.save
        @vote = @vote_form.vote
      end

      respond_to do |format|
        format.js
      end
    end

    def destroy
      @votable = find_votable
      @vote = current_user.votes.find_by!(votable: @votable)

      @vote.destroy

      respond_to do |format|
        format.js
      end
    end

    private

    def current_contribution_container
      current_site.contribution_containers.find_by!(slug: params[:contribution_container_id])
    end

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
