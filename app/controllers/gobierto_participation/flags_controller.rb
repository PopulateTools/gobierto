# frozen_string_literal: true

module GobiertoParticipation
  class FlagsController < GobiertoParticipation::ApplicationController
    def new
      @flaggable = find_flaggable
      flag_policy = FlagPolicy.new(current_user, flaggable)
      raise Errors::NotAuthorized unless flag_policy.create?

      @flag_form = FlagForm.new
    end

    def create
      flaggable = find_flaggable

      flag_policy = FlagPolicy.new(current_user, flaggable)
      raise Errors::NotAuthorized unless flag_policy.create?

      @flag_form = FlagForm.new(flag_params.merge(site_id: current_site.id,
                                                  user_id: current_user.id))

      if @flag_form.save
        @flag = true
      end

      respond_to do |format|
        format.js
      end
    end

    private

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
