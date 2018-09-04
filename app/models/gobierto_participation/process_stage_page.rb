# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStagePage < ApplicationRecord
    belongs_to :process_stage, class_name: "GobiertoParticipation::ProcessStage"
    belongs_to :page, class_name: "GobiertoCms::Page"

    def process
      Process.find(process_stage.process_id)
    end

    def public?
      process_stage.reload.public? && page.reload.public?
    end

    def parameterize
      { process_id: process.id, process_stage_id: process_stage.id, id: id }
    end
  end
end
