# frozen_string_literal: true

module GobiertoParticipation
  class ProcessInformationController < GobiertoParticipation::ApplicationController
    def show
      @process = find_process
      @information_text = @process.information_text
    end

    private

    def find_process
      ::GobiertoParticipation::Process.find_by_slug!(params[:process_id])
    end
  end
end
