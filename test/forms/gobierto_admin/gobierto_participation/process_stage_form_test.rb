# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessStageFormTest < ActiveSupport::TestCase

      def process
        @process ||= gobierto_participation_processes(:green_city_group_active_empty)
      end

      def test_initialize
        form_object = ProcessStageForm.new(process_id: process.id)

        assert_equal process, form_object.process
      end

    end
  end
end
