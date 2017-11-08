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
        results: process.stages.find_by!(stage_type: ProcessStage.stage_types[:results])
      }
    end

    def test_valid
      assert process_stage.valid?
    end

    def test_open
      refute stages[:information].open?
      assert stages[:meetings].open?
      refute stages[:results].open?
    end

    def test_past
      assert stages[:information].past?
      refute stages[:meetings].past?
    end

    def test_upcoming
      refute stages[:information].upcoming?
      refute stages[:meetings].upcoming?
      assert stages[:results].upcoming?
    end

    def test_current
      refute stages[:information].current?
      refute stages[:meetings].current?
      assert stages[:ideas].current?
      refute stages[:results].current?
    end
  end
end
