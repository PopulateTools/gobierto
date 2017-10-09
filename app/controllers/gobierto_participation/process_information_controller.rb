# frozen_string_literal: true

module GobiertoParticipation
  class ProcessInformationController < GobiertoParticipation::Processes::BaseController
    def show
      @information_text = current_process.information_text
    end
  end
end
