# frozen_string_literal: true

module GobiertoPeople
  class PersonInvitationsController < GobiertoPeople::ApplicationController

    # TODO: check submodule is enabled
    def index
      @invitations = current_site.invitations
    end

  end
end
