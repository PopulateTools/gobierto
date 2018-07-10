# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessStagePageTest < ActiveSupport::TestCase
    def process_stage_page
      @process_stage_page ||= gobierto_participation_process_stage_pages(:green_city_group_information_stage_page)
    end

    def test_valid
      assert process_stage_page.valid?
    end
  end
end
