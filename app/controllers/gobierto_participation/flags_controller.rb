# frozen_string_literal: true

module GobiertoParticipation
  class FlagsController < GobiertoParticipation::ApplicationController
    include User::VerificationHelper

    before_action(only: [:new, :create, :destroy]) { verify_user_in!(current_site) if current_contribution_container.visibility_user_level == "verified" }

    def new
      @flaggable = find_flaggable
      flag_policy = FlagPolicy.new(current_user)
      raise Errors::NotAuthorized unless flag_policy.create?

      @flag_form = FlagForm.new
    end

    def create
      @flaggable = find_flaggable

      if @flaggable.flagged_by_user?(current_user)
        flag = current_user.flags.find_by!(flaggable: @flaggable)
        flag.destroy
      end

      flag_policy = FlagPolicy.new(current_user)
      raise Errors::NotAuthorized unless flag_policy.create?

      @flag_form = FlagForm.new(flag_params.merge(site_id: current_site.id,
                                                  user_id: current_user.id))

      if @flag_form.save
        @flag = @flag_form.flag
      end

      respond_to do |format|
        format.js
      end
    end

    def destroy
      @flaggable = find_flaggable
      @flag = current_user.flags.find_by!(flaggable: @flaggable)

      @flag.destroy

      respond_to do |format|
        format.js
      end
    end

    private

    def current_contribution_container
      current_site.contribution_containers.find_by!(slug: params[:process_contribution_container_id])
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin, site_id: current_site.id }
    end

    def flag_params
      params.permit(
        :flag_weight,
        :flaggable_id,
        :flaggable_type
      )
    end

    def find_flaggable
      current_site.comments.find_by!(id: params[:flaggable_id])
    end
  end
end
