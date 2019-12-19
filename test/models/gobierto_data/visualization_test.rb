# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class VisualizationTest < ActiveSupport::TestCase
    def subject
      @subject ||= gobierto_data_visualizations(:users_count_visualization)
    end

    def test_valid
      assert subject.valid?
    end
  end
end
