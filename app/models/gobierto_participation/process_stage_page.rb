# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStagePage < ApplicationRecord
    belongs_to :process_stage, class_name: "GobiertoParticipation::ProcessStage"
    belongs_to :page, class_name: "GobiertoCms::Page"
  end
end
