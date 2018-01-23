# frozen_string_literal: true

require "test_helper"

module GobiertoIndicators
  class IndicatorShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_indicators_root_path
    end

    def user
      @user ||= users(:peter)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_indicator
      with_current_site(site) do
        visit @path

        assert has_content? "The indicators ITA (Index of Transparency of the City councils)"
      end
    end
  end
end
