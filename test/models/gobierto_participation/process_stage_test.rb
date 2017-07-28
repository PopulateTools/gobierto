require "test_helper"

module GobiertoParticipation
  class ProcessStageTest < ActiveSupport::TestCase
    def process_stage
      @process_stage ||= gobierto_participation_process_stages(:local_budgets_information_stage)
    end

    def test_valid
      assert process_stage.valid?
    end
  end
end
