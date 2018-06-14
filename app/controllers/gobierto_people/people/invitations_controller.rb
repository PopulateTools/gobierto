# frozen_string_literal: true

module GobiertoPeople
  module People
    class InvitationsController < BaseController
      def index
        @person_invitations = @person.invitations
      end

      def show
        @invitation = @person.invitations.find(params[:id])
      end
    end
  end
end
