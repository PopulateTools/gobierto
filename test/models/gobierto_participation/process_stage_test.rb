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

    def test_valid
      assert process_stage.valid?
    end

    def test_published
      assert process.stages.first.published?
    end

    def test_upcoming
      process.stages.last.upcoming?
    end

    def test_current
      assert process.stages.second.current?
    end
  end
end
