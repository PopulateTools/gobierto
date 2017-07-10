require "test_helper"

module GobiertoParticipation
  class ProcessStageTest < ActiveSupport::TestCase
    def process_stage
      @process_stage ||= gobierto_participation_process_stages(:green_city_first_stage)
    end

    def test_valid
      assert process_stage.valid?
    end
  end
end
