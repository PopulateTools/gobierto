# frozen_string_literal: true

module GobiertoPeople
  class PersonInvitationsController < GobiertoPeople::ApplicationController
    include DatesRangeHelper

    before_action :check_active_submodules

    def index
      @invitations = current_site.invitations.between_dates(filter_start_date, filter_end_date).order(start_date: :desc).limit(40)
    end

    private

    def check_active_submodules
      redirect_to gobierto_people_root_path unless invitations_submodule_active?
    end

  end
end
