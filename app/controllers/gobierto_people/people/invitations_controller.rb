# frozen_string_literal: true

module GobiertoPeople
  module People
    class InvitationsController < BaseController

      before_action :check_active_submodules

      def index
        @person_invitations = @person.invitations.between_dates(filter_start_date, filter_end_date)
      end

      def show
        @invitation = @person.invitations.find(params[:id])
      end

      private

      def check_active_submodules
        redirect_to gobierto_people_root_path unless invitations_submodule_active?
      end

    end
  end
end
