# frozen_string_literal: true

module GobiertoPeople
  class PersonInvitationsController < GobiertoPeople::ApplicationController

    before_action :check_active_submodules

    def index
      @invitations = current_site.invitations
    end

    private

    def check_active_submodules
      redirect_to gobierto_people_root_path unless invitations_submodule_active?
    end

  end
end
