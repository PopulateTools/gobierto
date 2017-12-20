# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessStageTest < ActiveSupport::TestCase
    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_stage
      @process_stage ||= gobierto_participation_process_stages(:local_budgets_information_stage)
    end

    def stages
      {
        information: process.stages.find_by!(stage_type: ProcessStage.stage_types[:information]),
        meetings: process.stages.find_by!(stage_type: ProcessStage.stage_types[:meetings]),
        ideas: process.stages.find_by!(stage_type: ProcessStage.stage_types[:ideas]),
        results: process.stages.find_by!(stage_type: ProcessStage.stage_types[:results]),
        polls: process.stages.find_by!(stage_type: ProcessStage.stage_types[:polls])
      }
    end

    def test_valid
      assert process_stage.valid?
    end

    def test_published
      assert stages[:information].published?
      assert stages[:meetings].published?
      refute stages[:ideas].published?
      refute stages[:results].published?
      refute stages[:polls].published?
    end

    def test_upcoming
      assert stages[:information].upcoming?
      refute stages[:meetings].upcoming?
    end

    def test_current
      refute stages[:information].current?
      assert stages[:meetings].current?
      refute stages[:ideas].current?
      refute stages[:results].current?
      refute stages[:polls].current?
    end
  end
end
