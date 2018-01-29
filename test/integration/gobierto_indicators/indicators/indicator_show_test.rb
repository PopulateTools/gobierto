# frozen_string_literal: true

require "test_helper"

module GobiertoIndicators
  class IndicatorShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_indicators_indicators_ita_path(2014)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_indicator
      with_javascript do
        with_current_site(site) do
          visit @path

          assert has_content? "The indicators ITA (Index of Transparency of the City councils)"
          assert has_content? "S'especifiquen dades biogràfiques de l'Alcalde/ssa i dels regidors/ores de l'Ajuntament?"
          within ".item-check" do
            assert page.find("i")["class"].include?("fa-check")
          end
        end
      end
    end
  end
end
